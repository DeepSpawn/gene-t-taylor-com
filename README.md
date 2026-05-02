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

`bitbucket-pipelines.yml` builds the site and syncs `dist/` to `s3://gene-t-taylor.com`,
then invalidates CloudFront distribution `E2RQV9ZUZPKBPW`. The default pipeline runs
on every push.
