import { defineCollection, z } from 'astro:content';

const posts = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    tags: z.array(z.string()).default([]),
    feature: z.string().optional(),
    published: z.boolean().default(true),
    // Multi-part series. When present, the post renders a kicker
    // ("<NAME> · PART <part> OF <total>") and prev/next links to the
    // nearest published siblings sharing the same `slug`.
    series: z
      .object({
        name: z.string(),
        slug: z.string(),
        part: z.number().int().positive(),
        total: z.number().int().positive(),
      })
      .optional(),
  }),
});

export const collections = { posts };
