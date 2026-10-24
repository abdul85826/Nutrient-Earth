---
name: imagekit
description: >-
  ImageKit real-time image & video optimization, CDN transformation, AI media processing,
  and digital asset management (DAM). Use when generating optimized media URLs, uploading
  assets, configuring Node/Python SDKs, or connecting to ImageKit MCP servers.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# ImageKit — Real-Time Media Optimization, CDN & DAM

ImageKit provides real-time media delivery, URL-based image/video transformations, AI background removal, and cloud asset management.

---

## 1. Installed SDKs & Packages

- **Node.js**: `@imagekit/nodejs` & `@imagekit/javascript` (installed globally via npm)
- **Python**: `imagekitio` (v5.11+ installed via pip)
- **CLI**: `imagekit-cli` (installed via pip)

---

## 2. Configuration & Credentials

Store keys strictly in `.env` (never commit keys to source code):

```env
IMAGEKIT_PUBLIC_KEY=your_public_key
IMAGEKIT_PRIVATE_KEY=your_private_key
IMAGEKIT_URL_ENDPOINT=https://ik.imagekit.io/your_id/
```

---

## 3. URL Transformation Engine

ImageKit performs real-time media transformations via query strings or path parameters (`tr:`):

### Common Transform Parameters
- `w-<number>`: Width (e.g. `w-500`)
- `h-<number>`: Height (e.g. `h-500`)
- `c-<mode>`: Crop mode (`maintain_ratio`, `force`, `at_least`, `at_max`)
- `fo-<focus>`: Smart focus / gravity (`auto`, `face`, `center`)
- `q-<number>`: Quality compression 1-100 (e.g. `q-80`)
- `f-<format>`: Format conversion (`auto`, `webp`, `avif`)
- `bl-<number>`: Blur intensity (e.g. `bl-10`)
- `bg-<color>`: Background color hex

### Example Transformation URLs
```
# Automatic WebP/AVIF with smart face crop
https://ik.imagekit.io/demo/sample.jpg?tr=w-400,h-400,fo-face,q-80,f-auto

# Aspect ratio preserve with thumbnail sizing
https://ik.imagekit.io/demo/sample.jpg?tr=w-300,c-at_max
```

---

## 4. SDK Usage

### Node.js (`@imagekit/nodejs`)
```typescript
import ImageKit from "@imagekit/nodejs";

const imagekit = new ImageKit({
  publicKey: process.env.IMAGEKIT_PUBLIC_KEY!,
  privateKey: process.env.IMAGEKIT_PRIVATE_KEY!,
  urlEndpoint: process.env.IMAGEKIT_URL_ENDPOINT!,
});

// Uploading a file
const uploadResponse = await imagekit.upload({
  file: fileBuffer, // or base64 or remote URL
  fileName: "hero_banner.jpg",
  folder: "/app_assets",
  tags: ["landing", "hero"],
});

// Generating a signed / transformed URL
const transformedUrl = imagekit.url({
  path: "/app_assets/hero_banner.jpg",
  transformation: [
    {
      width: "600",
      height: "400",
      crop: "maintain_ratio",
      quality: "80",
    },
  ],
});
```

### Python (`imagekitio`)
```python
from imagekitio import ImageKit
import os

imagekit = ImageKit(
    private_key=os.environ.get("IMAGEKIT_PRIVATE_KEY"),
    public_key=os.environ.get("IMAGEKIT_PUBLIC_KEY"),
    url_endpoint=os.environ.get("IMAGEKIT_URL_ENDPOINT"),
)

upload = imagekit.upload_file(
    file=open("local_image.jpg", "rb"),
    file_name="local_image.jpg",
    options={
        "response_fields": ["is_private_file", "tags"],
        "tags": ["profile", "avatar"],
    },
)
```

---

## 5. Model Context Protocol (MCP) Integration

ImageKit provides hosted MCP servers for AI coding assistants:
- **DevTools MCP** (query docs, build transformations):
  `https://devtools-mcp.imagekit.io/mcp`
- **DAM MCP** (browse and query media assets):
  `https://imagekit.io/mcp/dam`

---

## 6. Engineering & Security Rules

1. **Zero Secrets in Git**: Enforce `.env` usage for all private API keys.
2. **Deterministic Transforms**: Use explicit responsive image sets (`srcset`) with pre-calculated transformation widths (`w-320`, `w-640`, `w-1024`).
3. **Format Negotiation**: Always include `f-auto` or `f-webp` to minimize data transfer overhead on mobile clients.
