# Web performance audit — July 2026

Audited the built site (Astro 4 static build, deployed to S3 + CloudFront) with
Lighthouse 12 (simulated slow-4G mobile, headless Chromium) against `astro preview`,
plus a static analysis of the source, assets, and deploy pipeline.

## Headline results

| Page | Perf score | FCP | LCP | TBT | CLS |
|---|---|---|---|---|---|
| `/` (home) | **100** | 1.1 s | 1.8 s | 0 ms | 0 |
| `/posts/2026-07-18-end-of-code-review/` | **75** | 1.2 s | **19.0 s** | 0 ms | 0 |

The fundamentals are in very good shape: zero JavaScript shipped, a single 16 KB
stylesheet, self-hosted subset woff2 fonts with `font-display: swap` and preloads,
hashed `/_astro/*` assets on a long cache, short cache + invalidation for HTML.
Text pages are effectively as fast as a static site gets.

**The one real problem is the image pipeline.** Everything below is ordered by impact.

---

## 1. Post images: full-resolution PNGs, no lazy-loading, no dimensions (critical)

The code-review post references 11 images totalling **~4.2 MB** — full-res RGBA PNG
screenshots up to 1956 px wide, rendered into a 680 px reading column
(`$reading-width`). They are emitted as bare `<img src>` with:

- **no modern format** — Lighthouse estimates 2,927 KiB savings from WebP alone.
  Measured with sharp (already in `node_modules` via Astro): WebP q82 capped at
  1400 px turns a 4.5 MB sample into **0.9 MB (~80 % smaller)**, e.g.
  `ibm-news-1972-professionals.png` 984 K → 79 K.
- **no responsive `srcset`** — Lighthouse estimates a further 3,332 KiB on mobile.
- **no `loading="lazy"` / `decoding="async"`** — all 11 images download eagerly and
  compete with everything else; this is what drives LCP to 19 s on throttled mobile.
- **no `width`/`height`** — CLS is 0 only because every image sits below the first
  viewport; mid-read layout jumps still happen as images arrive.

### Recommended fix (one change solves all four)

Move post images out of `public/images/` into `src/` (e.g. `src/assets/…`) and
reference them with **relative paths** in the markdown
(`![alt](../../assets/end-of-code-review/foo.png)`). Astro's built-in image service
(sharp, already installed) then automatically emits WebP at a sane width, with
intrinsic `width`/`height`, `loading="lazy"`, `decoding="async"`, and a
**content-hashed filename** (which also fixes finding 2 for these files). The
`rehype-figures.mjs` plugin runs on the rendered HTML and keeps working; only the
`#size-hint` fragment handling needs a quick re-test with optimized images.

Minimal alternative if moving files is undesirable: pre-convert the PNGs to WebP in
`public/`, and extend `rehype-figures.mjs` to stamp `width`/`height` (via
`image-size` at build time) and `loading="lazy" decoding="async"` on every post image.

## 2. Immutable cache on unhashed files (high — correctness risk, not speed)

`deploy.yml` syncs everything except HTML/XML/TXT/JSON with
`Cache-Control: max-age=31536000,immutable`. That is correct for hashed `/_astro/*`
files, but it also applies to **unhashed** `/images/*` and `/assets/fonts/*`. If any
of those files is ever edited in place, the CloudFront invalidation clears the edge —
but returning visitors' **browsers** will serve the stale copy for up to a year with
no revalidation.

Fix: serve content by hashed filenames (the Astro image pipeline from finding 1 does
this for images), or give unhashed paths a softer policy, e.g.
`max-age=86400, stale-while-revalidate=604800`. Fonts are near-immutable in practice;
images are the real risk.

## 3. ~2.3 MB of dead assets deployed, plus unreferenced icon fonts (medium)

Referenced nowhere in `src/`:

- Images (~2.3 MB): `tussock2.png` (607 K), `Vue_de_Port-au-Prince…png` (913 K),
  `typewriter.jpg` (473 K), `soft-trees.jpg` (248 K), `portrait@2x.jpg`,
  `TheBlackJacobins.jpg`, `TheBlackJacobinsCover.jpg`, `shipit-rPcLSCAD.jpg`
- Legacy icon fonts: `public/assets/fonts/icomoon.{eot,ttf,svg,woff,dev.svg}` and the
  duplicate `public/assets/css/fonts/Icons.*` set

These don't slow any page down, but they are uploaded on every deploy and are
publicly served. Separately, 16 of the 24 PNGs in
`public/images/end-of-code-review/` (~3.8 MB) are not referenced by part 1 —
presumably staged for parts 2–3; fine to keep, just noting they are already public.

## 4. Render-blocking stylesheet (low)

The single 16 KB `/_astro/about.*.css` is render-blocking; Lighthouse estimates
~460 ms on throttled mobile. With a 1-hour HTML cache and a site this small, inlining
it (`build: { inlineStylesheets: 'always' }`) would trade ~14 KB per page view for
one fewer round trip on first visit. Defensible either way — the cross-page cache
win is small at this page count, but so is the duplication. Not urgent.

## 5. Verify at the CloudFront/distribution level (couldn't check from this sandbox)

The deploy stores objects uncompressed in S3, so text compression depends entirely on
the distribution config. Worth confirming in the console:

- **"Compress objects automatically" is ON** (gzip + Brotli) — without it, HTML/CSS/
  fonts ship uncompressed.
- **HTTP/2 and HTTP/3** are enabled on the distribution.
- A cache policy that forwards no cookies/query strings for this static content.

## 6. Deploy pipeline nits (low)

- The HTML sync step has no `--delete`, and the asset sync's `--delete` won't remove
  excluded (HTML) files — so deleted pages live on in S3/CloudFront until touched
  manually. Add `--delete` to the HTML sync too.
- `create-invalidation --paths "/*"` on every push is fine at this volume
  (1,000 free paths/month).

## What's already good (no action)

- Zero client-side JavaScript; 13 static pages build in ~2 s.
- Fonts: subset latin/latin-ext woff2, variable weights, `font-display: swap`,
  `unicode-range`, and preloads for exactly the three above-the-fold faces.
- Hashed CSS with immutable caching; short-cache HTML + invalidation on deploy.
- Redirect stubs are tiny static files with `canonical` + `noindex`; sitemap, RSS,
  and structured data all present and small.

> **Update:** finding 1 has been fixed on this branch — post images moved to
> `src/assets/` and optimized by Astro's image pipeline. Re-audit of the post
> page: perf score 75 → **97**, LCP 19.0 s → **2.2 s**, page weight
> 4,352 KiB → **295 KiB**. Findings 2–6 remain open.

## Suggested order of work

1. Move post images into `src/` and let Astro's image service optimize them
   (fixes format, sizing, lazy-loading, dimensions, and cache-hashing in one go).
2. Add `--delete` to the HTML sync step; soften cache-control for any remaining
   unhashed `public/` paths.
3. Delete the unused images and icomoon/Icons font files from `public/`.
4. Confirm CloudFront compression + HTTP/2/3 in the console.
