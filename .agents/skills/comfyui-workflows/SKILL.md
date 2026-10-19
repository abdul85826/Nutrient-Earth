---
name: comfyui-workflows
description: >-
  ComfyUI workflow generation, graph execution, custom node integration, and diffusion pipelines
  (Stable Diffusion, Flux, SDXL). Use when building image/video generation pipelines,
  node-based automation, and API connectors.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# ComfyUI Workflows & Generative Diffusion

This skill provides patterns for programmatic execution of ComfyUI graph workflows, prompt conditioning, model selection, and API integration.

---

## 1. ComfyUI API Execution Architecture

ComfyUI exposes a REST and WebSocket API (typically default on port `8188`):
- `POST /prompt`: Queues a prompt workflow JSON for execution.
- `GET /history/{prompt_id}`: Fetches outputs, generated image filenames, and error traces.
- `GET /view`: Downloads the resulting image/video buffer.
- `WS /ws?clientId={id}`: Receives real-time node progress events (`executing`, `progress`).

---

## 2. API Workflow Client Pattern

```python
import json
import urllib.request
import urllib.parse

def queue_prompt(workflow_prompt: dict, server_address="127.0.0.1:8188"):
    data = json.dumps({"prompt": workflow_prompt}).encode('utf-8')
    req = urllib.request.Request(f"http://{server_address}/prompt", data=data)
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read())

def get_image(filename: str, subfolder="", folder_type="output", server_address="127.0.0.1:8188"):
    params = urllib.parse.urlencode({"filename": filename, "subfolder": subfolder, "type": folder_type})
    with urllib.request.urlopen(f"http://{server_address}/view?{params}") as response:
        return response.read()
```

---

## 3. Node Graph Best Practices
- **Checkpoint Loaders**: Cache base models (Flux.1 Schnell/Dev, SDXL) in VRAM; avoid reloading model weights per query.
- **KSampler Configuration**:
  - Flux: Prefer `euler` sampler with `simple` or `sgm_uniform` scheduler (20–28 steps).
  - SDXL: Prefer `dpmpp_2m` with `karras` scheduler (25–35 steps, CFG 5.5–7.0).
- **ControlNet & LoRA Stacking**: Keep LoRA weights bounded between `0.6` and `0.85` to prevent artifact blowout.
