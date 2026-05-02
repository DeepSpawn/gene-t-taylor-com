# gene-t-taylor.com

Personal site for Gene Taylor, built with [Astro](https://astro.build/).

## Develop

```bash
npm install
npm run dev    # http://localhost:4321
```

## Build

```bash
npm run build  # outputs to dist/
npm run preview
```

## Structure

```
src/
  content/posts/   # blog posts (markdown)
  layouts/         # BaseLayout, PostLayout, PageLayout
  components/      # Head, SiteHeader, Footer, SocialMeta, PostList
  pages/           # routes — index, about, now, resume, archive, 404, posts/[slug], feed.xml, sitemap.xml
  styles/          # SCSS
public/            # static assets, copied verbatim to dist/
                   # also contains the .html → /slug/ redirect stubs
```

## Deploy

`.github/workflows/deploy.yml` runs on every push to `master`: builds the site, syncs
`dist/` to `s3://gene-t-taylor.com` (long cache for assets, short cache for HTML/XML/JSON),
and invalidates CloudFront distribution `E2RQV9ZUZPKBPW`.

Required GitHub repo secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (the bucket's region — likely `us-east-1` or `ap-southeast-2`)
- `CLOUDFRONT_DISTRIBUTION_ID` — `E2RQV9ZUZPKBPW`
