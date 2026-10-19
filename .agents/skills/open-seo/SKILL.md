---
name: open-seo
description: >-
  Technical SEO optimization, structured data (JSON-LD), OpenGraph/Twitter social cards,
  Core Web Vitals, semantic HTML5, sitemap automation, and search crawler indexability.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Open SEO — Technical Search Engine Optimization

This skill guides the implementation of modern technical SEO, crawl optimization, structured metadata, and Core Web Vitals compliance.

---

## 1. Essential Meta Tags & Social Cards

Always implement comprehensive document heads:

```html
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Nutrient Earth — Health Context & Decision Intelligence</title>
  <meta name="description" content="Nutrient Earth transforms fragmented health data into trusted, evidence-based, personalized guidance." />
  <link rel="canonical" href="https://nutrientearth.com/" />

  <!-- OpenGraph / Facebook -->
  <meta property="og:type" content="website" />
  <meta property="og:url" content="https://nutrientearth.com/" />
  <meta property="og:title" content="Nutrient Earth — Continuous Health Memory" />
  <meta property="og:description" content="Personalized health context backed by deterministic clinical evidence." />
  <meta property="og:image" content="https://nutrientearth.com/og-banner.png" />

  <!-- Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Nutrient Earth" />
  <meta name="twitter:description" content="Continuous Health Context & Decision Intelligence Platform." />
  <meta name="twitter:image" content="https://nutrientearth.com/og-banner.png" />
</head>
```

---

## 2. Structured Data (JSON-LD)

Embed Schema.org structured data directly inside a `<script type="application/ld+json">` tag:

```json
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Nutrient Earth",
  "applicationCategory": "HealthApplication",
  "operatingSystem": "Web, Android, iOS",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "description": "Continuous health context and evidence-based personalized guidance platform."
}
```

---

## 3. Technical Indexing & Crawl Rules

1. **`robots.txt`**:
   ```
   User-agent: *
   Allow: /
   Disallow: /api/
   Disallow: /private/
   Sitemap: https://nutrientearth.com/sitemap.xml
   ```
2. **Heading Hierarchy**: Exactly one `<h1>` per page reflecting the primary entity or title; nest subsequent sections in sequential order (`<h2>` -> `<h3>`).
3. **Core Web Vitals Optimization**:
   - Preload critical hero images (`<link rel="preload" as="image" href="..." fetchpriority="high">`).
   - Reserve image dimensions (`width` and `height` attributes) to prevent Cumulative Layout Shift (CLS).
