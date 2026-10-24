---
name: hermes-studio
description: >-
  Self-hosted web UI, orchestration studio, and multi-agent dashboard for Hermes Agent.
  Use for managing Hermes agents, visual execution traces, skill execution, automated cron
  schedules, approval workflows, and gateway API communication.
metadata:
  author: ant-agent
  version: "1.0.0"
---

# Hermes Studio — Self-Hosted Agent Orchestration Dashboard

Hermes Studio (`JPeetz/Hermes-Studio`) is a modern web UI and dashboard built for managing and orchestrating Nous Research Hermes agents.

---

## 1. Repository & Installation Directory

- **Repository Path**: `C:\Users\admin\tools\Hermes-Studio`
- **Frontend Stack**: Vite, React, TypeScript, TailwindCSS
- **Hermes Gateway Port**: `8642` (HTTP API server)
- **Studio Dashboard Port**: `http://localhost:5173` (or `3000`)

---

## 2. Core Capabilities

1. **Multi-Agent Orchestration**:
   - Visual dashboard for monitoring agent states, conversation threads, and tool executions.
2. **Skill & Tool Management**:
   - Inspect, enable, or disable skills and tool definitions loaded by the agent runtime.
3. **Approval Workflows**:
   - Human-in-the-loop review for shell commands, database modifications, and sensitive API calls.
4. **Cron Job Scheduling**:
   - Automated recurring prompts and background tasks configured within the dashboard.
5. **Visual Knowledge & Execution Graphs**:
   - Real-time graph inspection of memory retrieval, subagent delegation, and task DAGs.

---

## 3. Running Hermes Studio

### Prerequisite: Hermes Gateway Configuration
Ensure Hermes has HTTP API access enabled in your Hermes config (`~/.hermes/.env`):
```env
API_SERVER_ENABLED=true
API_SERVER_PORT=8642
```

### Starting the Studio Web Interface
Navigate to the Hermes Studio directory:
```bash
cd "C:\Users\admin\tools\Hermes-Studio"
pnpm dev
```
Open `http://localhost:5173` in your browser to interact with Hermes Studio.

### Docker Alternative
```bash
cd "C:\Users\admin\tools\Hermes-Studio"
docker build -t hermes-studio .
docker run -d -p 3000:3000 --name hermes-studio hermes-studio
```
