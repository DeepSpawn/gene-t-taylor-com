import { getCollection } from 'astro:content';
import type { APIContext } from 'astro';

export async function GET(context: APIContext) {
  const site = context.site!.toString().replace(/\/$/, '');
  const posts = await getCollection('posts', ({ data }) => data.published !== false);
  const sortedPosts = posts.sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());

  const staticPages = ['/', '/about/', '/now/', '/resume/', '/archive/'];

  const urls = [
    ...staticPages.map((path) => ({
      loc: `${site}${path}`,
      lastmod: undefined,
    })),
    ...sortedPosts.map((post) => ({
      loc: `${site}/posts/${post.slug}/`,
      lastmod: post.data.pubDate.toISOString().slice(0, 10),
    })),
  ];

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls
  .map(
    (u) =>
      `  <url>\n    <loc>${u.loc}</loc>${u.lastmod ? `\n    <lastmod>${u.lastmod}</lastmod>` : ''}\n  </url>`,
  )
  .join('\n')}
</urlset>
`;

  return new Response(xml, {
    headers: { 'Content-Type': 'application/xml' },
  });
}
