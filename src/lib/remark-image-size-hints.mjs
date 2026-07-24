// Strip #small / #medium / #wide size-hint fragments from Markdown image URLs
// before Astro collects images for optimization.
//
// Authors write ![alt](./foo.png#medium). Astro's image pipeline resolves the
// URL as a Vite import, so the fragment must not reach it. This plugin removes
// the fragment from the URL and carries the hint across to the rendered <img>
// as a data-size attribute, where rehype-figures turns it into a
// post-figure--<hint> class on the wrapping <figure>.
//
// Runs before Astro's remark-collect-images (user remark plugins always do),
// so both optimized (relative-path) and public/ (absolute-path) images are
// covered by the same syntax.

import { visit } from 'unist-util-visit';

const SIZE_HINTS = new Set(['small', 'medium', 'wide']);

export default function remarkImageSizeHints() {
  return (tree) => {
    visit(tree, 'image', (node) => {
      const hashIndex = node.url.indexOf('#');
      if (hashIndex === -1) return;
      const hint = node.url.slice(hashIndex + 1).toLowerCase();
      node.url = node.url.slice(0, hashIndex);
      if (!SIZE_HINTS.has(hint)) return;
      node.data ??= {};
      node.data.hProperties ??= {};
      node.data.hProperties['data-size'] = hint;
    });
  };
}
