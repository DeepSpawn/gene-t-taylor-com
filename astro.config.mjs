import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import rehypeFigures from './src/lib/rehype-figures.mjs';

export default defineConfig({
  site: 'https://gene-t-taylor.com',
  output: 'static',
  build: {
    format: 'directory',
  },
  integrations: [mdx()],
  markdown: {
    rehypePlugins: [rehypeFigures],
  },
  // Note: trailing-slash directory redirects only — handled by Astro.
  // The .html-source redirects are emitted as static files under public/
  // (see public/posts/*.html and public/about.html etc.), because Astro's
  // `build.format: 'directory'` would otherwise emit them as
  // `/about.html/index.html`.
  redirects: {
    '/2016/11/13/mockito-varargs-matcher/': '/posts/2016-11-13-mockito-varargs-matcher/',
    '/2016/11/07/haskell-course/': '/posts/2016-11-07-haskell-course/',
    '/2016/07/20/CompletableFuture-sequence/': '/posts/2016-07-20-CompletableFuture-sequence/',
    '/2016/06/28/pattern-matching-in-java/': '/posts/2016-06-28-pattern-matching-in-java/',
    '/2016/03/26/guava-immutablemap-collector/': '/posts/2016-03-26-guava-immutablemap-collector/',
  },
});
