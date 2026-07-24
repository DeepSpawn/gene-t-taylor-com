// Turn Markdown images into real <figure> / <figcaption> markup.
//
// Markdown renders a block image as a bare <img> inside a <p>, often glued to a
// lead-in sentence or an italic caption because there is no blank line between
// them. This plugin normalises that: any paragraph containing a single image is
// rebuilt as
//
//   <p>lead-in prose…</p>            (only if there was any non-caption prose)
//   <figure class="post-figure">
//     <img …>
//     <figcaption>caption…</figcaption>   (only if the paragraph had an <em>)
//   </figure>
//
// A caption is written in Markdown as a whole-line emphasis (*like this*) sitting
// immediately before or after the image. Plain text in the same paragraph is
// treated as lead-in prose and kept as its own paragraph.
//
// Size hint: append #small / #medium / #wide to the image URL, e.g.
//   ![alt](./foo.png#medium)
// remark-image-size-hints strips the fragment (Astro's image pipeline can't
// resolve URLs containing one) and carries the hint here as a data-size
// attribute, which this plugin lifts off the <img> and maps to a modifier
// class (post-figure--medium) so the figure can be constrained in CSS.

const SIZE_HINTS = new Set(['small', 'medium', 'wide']);

function isElement(node, tagName) {
  return Boolean(node) && node.type === 'element' && node.tagName === tagName;
}

function isWhitespaceText(node) {
  return Boolean(node) && node.type === 'text' && node.value.trim() === '';
}

function hasContent(node) {
  if (!node) return false;
  if (node.type === 'text') return node.value.trim() !== '';
  return node.type === 'element';
}

export default function rehypeFigures() {
  return (tree) => walk(tree);
}

function walk(node) {
  if (!node || !Array.isArray(node.children)) return;

  for (const child of node.children) walk(child);

  const rebuilt = [];
  for (const child of node.children) {
    if (isElement(child, 'p') && paragraphHasSingleImage(child)) {
      rebuilt.push(...transformImageParagraph(child));
    } else {
      rebuilt.push(child);
    }
  }
  node.children = rebuilt;
}

function paragraphHasSingleImage(p) {
  const images = p.children.filter((c) => isElement(c, 'img'));
  return images.length === 1;
}

function transformImageParagraph(p) {
  const significant = p.children.filter((c) => !isWhitespaceText(c));
  const img = significant.find((c) => isElement(c, 'img'));
  const captionEm = significant.find((c) => isElement(c, 'em'));
  const prose = significant.filter((c) => c !== img && c !== captionEm);

  const out = [];

  if (prose.some(hasContent)) {
    out.push({
      type: 'element',
      tagName: 'p',
      properties: {},
      children: trimEdges(prose),
    });
  }

  const sizeClass = extractSizeClass(img);
  const figure = {
    type: 'element',
    tagName: 'figure',
    properties: { className: ['post-figure', ...(sizeClass ? [sizeClass] : [])] },
    children: [img],
  };
  if (captionEm) {
    figure.children.push({
      type: 'element',
      tagName: 'figcaption',
      properties: {},
      children: captionEm.children,
    });
  }
  out.push(figure);

  return out;
}

function extractSizeClass(img) {
  if (!img.properties) return null;
  // hProperties set in remark keep their literal key; hast-native properties
  // would camelize it. Accept either spelling.
  const hint = img.properties['data-size'] ?? img.properties.dataSize;
  delete img.properties['data-size'];
  delete img.properties.dataSize;
  return typeof hint === 'string' && SIZE_HINTS.has(hint)
    ? `post-figure--${hint}`
    : null;
}

function trimEdges(nodes) {
  const copy = nodes.map((n) => ({ ...n }));
  if (copy.length && copy[0].type === 'text') {
    copy[0] = { ...copy[0], value: copy[0].value.replace(/^\s+/, '') };
  }
  const last = copy.length - 1;
  if (last >= 0 && copy[last].type === 'text') {
    copy[last] = { ...copy[last], value: copy[last].value.replace(/\s+$/, '') };
  }
  return copy;
}
