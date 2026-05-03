---
layout: ../layouts/PageLayout.astro
title: About
description: "Gene Taylor — Senior Engineering Manager at Atlassian, Sydney. Philosophy background; leading a team extracting Jira's core issue API onto DynamoDB."
noSocial: true
feature: tussock2.png
---

<img src="/images/portrait.jpg" style="width:20%" alt="Gene Taylor">

I'm a Senior Engineering Manager at [Atlassian](https://atlassian.com), based in Sydney. I've been here for over a decade, joining as a graduate developer in 2015 and growing through senior IC roles into management. Most of that time has been in and around Jira: I've worked on the developer tools space, React performance on the Jira frontend, and microservice extraction projects in the backend.

I currently lead one of two teams on Jira's Issue Backend — about 17 engineers extracting the core issue API from the Jira monolith into a new service backed by a DynamoDB document model. Our sibling team owns the new service; my team owns the migration path — moving every read and write of the issue object onto the new system without disrupting the product.

Before software, I studied Philosophy at the [University of Otago](https://www.otago.ac.nz/), where I picked up a Bachelor of Arts and a Postgraduate Diploma. My PG Dip dissertation was on Homotopy Type Theory and the foundations of mathematics, which is how I found my way into formal methods, type systems, and eventually a graduate role in industry via a Diploma for Graduates in Computer Science.

These days I think a lot about scaling engineering teams with the right balance of processes, and how we can best incorporate AI into the software development lifecycle without compromising reliability.

I write about that kind of thing here, when I find the time.

You can reach me at [contact@gene-t-taylor.com](mailto:contact@gene-t-taylor.com), or find me on [LinkedIn](https://www.linkedin.com/in/genetaylor/) and [GitHub](https://github.com/DeepSpawn).

# Colophon

- Built with [Astro](https://astro.build/), a modern static site framework.
- Hosted on [S3](https://aws.amazon.com/s3/) behind [CloudFront](https://aws.amazon.com/cloudfront/), deployed via [GitHub Actions](https://github.com/features/actions).

<sub><sup>Header photo by [Tomas Sobek](https://www.flickr.com/photos/tomas_sobek/16816569066) / [CC BY](https://creativecommons.org/licenses/by/2.0/).</sup></sub>
