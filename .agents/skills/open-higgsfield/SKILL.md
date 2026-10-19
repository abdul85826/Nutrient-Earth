---
name: open-higgsfield
description: >-
  AI video generation, cinematic prompt engineering, camera motion control,
  and generative video editing (Higgsfield AI, Omni Flash, Runway, Sora, Luma API patterns).
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Open Higgsfield & Generative Video Engineering

This skill provides prompt formulations, motion parameterization, and API workflows for generative AI video creation and cinematic storytelling.

---

## 1. Cinematic Video Prompt Structure

Structure video generation prompts with 4 distinct anchors:

1. **Subject**: Detailed physical description, clothing, expression, age, textures.
2. **Action / Dynamics**: Explicit physical movement (e.g. *turning head slowly towards camera with a subtle smile*).
3. **Camera Motion**: Precise camera terminology:
   - `Dolly zoom` (vertigo effect)
   - `Orbit / Pan 360` (rotation around subject)
   - `Crane shot / Pedestal down`
   - `FPV drone dive`
   - `Static locked-off shot`
4. **Lighting & Atmosphere**: Volumetric lighting, anamorphic lens flares, golden hour, 35mm film grain, 8k hyper-detailed photorealism.

---

## 2. Image-to-Video (First Frame Transitions)

When animating an existing image or UI mockup:
- Maintain source aspect ratio (`16:9` or `9:16`).
- Define motion scale (low: 2–4 for subtle human breathing/wind; high: 7–10 for fast action/explosions).
- Avoid prompt conflicts with the source image (do not alter base colors or established geometry).

---

## 3. Video Processing & Optimization

When serving generated MP4/WebM files to web or mobile clients:
- Transcode with `ffmpeg` using H.264 / AAC for maximum device compatibility:
  ```bash
  ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k -movflags +faststart output.mp4
  ```
- Use `-movflags +faststart` to move the `moov` atom to the beginning of the file for instant web streaming.
