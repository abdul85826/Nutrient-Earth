---
name: agent-reach
description: >-
  Local zero-API multi-platform web browsing, deep research, and channel extraction.
  Use when querying content from GitHub, YouTube, Twitter/X, Reddit, RSS/Atom, Bilibili,
  V2EX, or scraping web articles via Jina Reader.
metadata:
  author: ant-agent
  version: "1.5.0"
---

# Agent Reach — Zero-API Multi-Channel Web & Social Search

Agent Reach (`agent-reach`) is an open-source local-first tool providing zero-API intelligence gathering across web pages, developer repositories, video platforms, and social media networks.

---

## 1. Environment & Binary Path

- **Global Command**: `agent-reach` (available directly in PowerShell and Command Prompt)
- **Executable**: `C:\Users\admin\AppData\Roaming\Python\Python314\Scripts\agent-reach.exe`
- **Configuration Directory**: `C:\Users\admin\.config\`

---

## 2. Core CLI Operations

### Health & Channel Diagnostics
Verify available extractors and channels:
```bash
agent-reach doctor
```

### Search Operations
Execute searches across supported search backends:
```bash
agent-reach search "query terms" --limit 10
```

### Direct Channel Extraction
- **Arbitrary Webpage Content (via Jina Reader)**:
  Extract clean markdown from any URL without JavaScript blockers or paywall scripts:
  ```bash
  curl -s "https://r.jina.ai/<target_url>"
  ```
- **GitHub Repositories & Commits**:
  Query issues, releases, and repository data:
  ```bash
  gh repo view <owner/repo>
  gh issue list --repo <owner/repo> --limit 10
  ```
- **YouTube Metadata & Subtitles**:
  Extract transcript and audio info via yt-dlp with configured Node JS runtime:
  ```bash
  yt-dlp --skip-download --write-auto-sub --sub-lang en --output "%(title)s.%(ext)s" "<youtube_url>"
  ```
- **Bilibili Content**:
  Query Bilibili search and video metadata via public API.
- **RSS / Atom Feeds**:
  Ingest live updates from industry newsletters, tech blogs, and research feeds.

---

## 3. Best Practices for Coding Agents

1. **Verify Connectivity**: Always check channel status with `agent-reach doctor` if an external fetch fails.
2. **Deterministic Output**: Pipe extraction outputs into local scratch files before LLM summarization.
3. **No Secret Leaks**: Never query URLs containing authentication tokens or private session cookies.
