# Scale Up v0.9.1 — Quick Start Guide

**AI-Assisted Account Strategy Planner for Technical Sales**
Deployment Pack v14 · Tauri 2 + React + TypeScript

---

## What It Does

Paste account notes, CRM exports, call summaries, or meeting notes. Scale Up generates a structured account strategy plan: org chart, solution architecture, stakeholder map, action items, RACI, red flags, and more. Works offline (deterministic) or enriched with an LLM.

---

## Install & Build

### Prerequisites

- Windows 10/11 x64
- Python 3.10+
- Internet connection (first build only)

### Build Steps

1. Extract `scale_up_windows_deploy_pack_v14.zip` to your Desktop
2. Right-click `deploy.bat` → **Run as administrator**
3. Wait for all 5 stages to complete (~5 minutes first build)
4. The MSI installer is in `runtime\artifacts\`
5. Double-click the MSI to install, or run `scale-up-app.exe` from `workspace\scale-up-app\src-tauri\target\release\`

### Rebuild After Code Changes

If you update source files and want to rebuild without re-running the full deploy:

```
cd workspace\scale-up-app
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
npm run tauri:build
```

---

## Using Ollama (Local AI)

### First-Time Setup

1. Install Ollama from [ollama.com](https://ollama.com)
2. Pull a model: `ollama pull gemma3:4b` (or any model you prefer)
3. **Set CORS** — required for Scale Up to connect:
   - Press `Win + R` → type `sysdm.cpl` → Enter
   - Advanced tab → Environment Variables
   - Under System variables, click New:
     - Name: `OLLAMA_ORIGINS`
     - Value: `*`
   - Click New again:
     - Name: `OLLAMA_KEEP_ALIVE`
     - Value: `-1`
   - Click OK → OK → OK
4. Restart Ollama (right-click tray icon → Quit, then reopen from Start menu)

### Configure in Scale Up

1. Go to **Config** tab
2. In the API key field, paste: `http://127.0.0.1:11434`
3. It auto-detects as "Ollama"
4. Open **Advanced Settings** → change **Model** to your installed model (e.g. `gemma3:4b`)
5. Also update **Local Fallback** → Local Model to the same
6. Click **Run Health Check** — should show "Primary: healthy"

### Warm Up the Model

If Health Check shows "unreachable", the model may need loading. Run in cmd:

```
curl http://127.0.0.1:11434/api/generate -d "{\"model\":\"gemma3:4b\",\"keep_alive\":-1,\"prompt\":\"hi\",\"stream\":false}"
```

Wait for the response (up to 60 seconds on first load), then retry Health Check.

### Recommended Models

| Model | Size | Quality | Speed |
|-------|------|---------|-------|
| `gemma3:4b` | 3.3 GB | Basic extraction | Fast |
| `llama3.1:8b` | 4.7 GB | Good extraction | Medium |
| `qwen2.5:14b` | 8.5 GB | Strong extraction | Slower |
| `llama3.3:70b` | 40 GB | Best extraction | Requires 48GB+ RAM |

Smaller models may produce partial or malformed LLM output — the app falls back to deterministic mode automatically.

---

## Using Cloud AI Providers

Paste any of these in the API key field — provider is auto-detected:

| Provider | Key Format | Free Tier |
|----------|-----------|-----------|
| Groq | `gsk_...` | Yes — fast, recommended |
| OpenAI | `sk-...` | No |
| Gemini | `AIza...` | Yes |
| Anthropic | `sk-ant-...` | No |

---

## Features

### Plan Tab
- **Generate Plan** — paste text, click generate
- **Clear** — reset everything for a new plan
- **Export MD** — saves Markdown file to Desktop
- **Export DOCX** — saves Word document to Desktop
- **Focus Mode** — hides side panels for reading
- **Expand diagrams** — click ⛶ on any diagram for fullscreen with zoom

### History Tab
- Auto-saves last 20 plans
- Click any entry to reload it
- Clear History to wipe all

### Config Tab
- AI provider setup (cloud or local)
- Serper API key for web research (optional, free at serper.dev)
- Local Ollama fallback
- Prompt overrides for each pipeline stage
- Knowledge Base — sync a folder of .txt/.csv/.docx files for RAG context
- Diagnostics — health check, export trace

### Theme Toggle
- ☀ Light / ☾ Dark
- Persists across sessions

---

## Modes

| Mode | When | What Happens |
|------|------|-------------|
| **Deterministic** | No AI configured | Regex + knowledge graph parsing. 100% grounded. |
| **Pipeline** | AI provider healthy | Web research → LLM extraction → merge with deterministic. Richer output. |

The plan always starts with deterministic analysis. LLM enrichment is layered on top — never replaces grounded data.

---

## Output Fields

Account, Division, Project, Sector, State of Account, Roles, Contacts, Champion, Critical Project Issue, Solution, Advantage, Case Study, Action Items, RACI, Red Flags, Projects, Opportunities, Signals, Org Chart (Mermaid + ALT + Node Outline), Solution Architecture (Mermaid + ALT + Flow Outline), Account Mind Map.

---

## Troubleshooting

**Ollama "unreachable"**
- Use `http://127.0.0.1:11434` not `http://localhost:11434`
- Set `OLLAMA_ORIGINS=*` as system environment variable
- Restart Ollama after setting env vars
- Warm the model with curl before health check

**Export buttons do nothing**
- Files save to your Desktop folder
- Check Desktop for `ScaleUp_*.md` or `ScaleUp_*.docx` files

**Build fails on webview2-com**
- The `CARGO_BUILD_JOBS=4` setting in deploy.bat prevents this
- If building manually, run `set CARGO_BUILD_JOBS=4` before `npm run tauri:build`

**DuckDuckGo returns no results**
- DDG HTML scraping is unreliable
- Add a Serper API key (free, 2500 searches/month) for reliable web research

**Diagrams show raw code**
- Mermaid rendering failed — usually caused by special characters in input
- The text fallback still contains the full diagram information

---

## Credits

Prototype by Orven
Inspired by [SE Diligence by OF](https://bendicttoh.github.io/sedbyof/)
