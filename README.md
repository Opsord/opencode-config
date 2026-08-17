# opencode global config

Global [opencode](https://opencode.ai) configuration stored at `~/.config/opencode/`.

## File structure

```
~/.config/opencode/
├── opencode.json            # Main config: permissions, plugins, MCP servers
├── opencode.jsonc           # Secondary config: codebase-memory-mcp server
├── AGENTS.md                # Global system prompt injected into every session
├── package.json             # Plugin dependencies (gitignored)
├── package-lock.json        # Lock file (gitignored)
├── node_modules/            # Installed plugins (gitignored)
├── agents/                  # Custom agent definitions
│   ├── gato-pm.md           # Technical PM: plans features, generates checklists
│   ├── hormiga-dev.md       # Senior dev: executes implementation plans
│   ├── raton-auditor.md     # Auditor: quality, security, YAGNI (subagent)
│   ├── cuervo-pensador.md   # opencode config specialist
│   ├── pato-poderoso.md     # Heavy-duty execution agent (broad permissions)
│   ├── codebase-memory.md   # Graph lookup Tier 2 (subagent)
│   ├── codebase-memory-auditor.md  # Graph audit Tier 3 (subagent)
│   └── codebase-memory-scout.md   # Fast graph lookup Tier 1 (subagent)
├── skills/
│   └── codebase-memory/
│       └── SKILL.md         # Custom skill for the knowledge graph
├── plugins/
│   └── cbm-augment.ts       # Plugin: enriches grep/glob results with graph context
└── .figma-api-key           # Figma API key (gitignored)
```

## Installed plugins

| Plugin | Version | Description |
|--------|---------|-------------|
| `superpowers` | github:obra/superpowers | Skills framework: brainstorming, TDD, systematic debugging, etc. |
| `@dietrichgebert/ponytail` | ^4.9.0 | Lazy dev mode: enforces the simplest solution that works (YAGNI) |
| `@opencode-ai/plugin` | 1.18.4 | opencode plugin SDK (required by the plugins above) |

## Active MCP servers

| Server | Description |
|--------|-------------|
| `codebase-memory-mcp` | Codebase knowledge graph: structural search, call tracing, impact analysis |
| `figma-xintec` | Figma integration via `figma-developer-mcp` (npx) |

## Available agents

Invoke with `@agent-name` inside opencode:

| Agent | Mode | Role |
|-------|------|------|
| `@gato-pm` | primary | Plans features: analyzes requirements, explores code, generates detailed checklists |
| `@hormiga-dev` | primary | Executes plans: implements code following gato-pm's checklist |
| `@raton-auditor` | subagent | Audits changes: security, architecture, performance, YAGNI |
| `@cuervo-pensador` | primary | Audits and optimizes the opencode config itself |
| `@pato-poderoso` | primary | Heavy-duty execution with maximum autonomy (large refactors, UI iterations) |
| `@codebase-memory` | subagent | Graph lookup Tier 2 (directed verification) |
| `@codebase-memory-auditor` | subagent | Graph audit Tier 3 (full coverage) |
| `@codebase-memory-scout` | subagent | Graph lookup Tier 1 (fast and provisional) |

## Model vision support (OpenCode Zen / Go)

_Last updated: 2026-08-16 — source: [models.dev](https://models.dev/api.json)._

Needed for `impeccable`'s `live` (annotated screenshots) and `critique`/`audit` (visual inspection) flows. Re-check `models.dev` before trusting this table long-term — providers add/drop image support between releases.

### ✅ Vision-capable (accepts images)

| Model | Availability | Input modalities |
|-------|---------------|-------------------|
| Claude Sonnet 5 / Opus 5 / Opus 4.5-4.8 / Fable 5 / Haiku 4.5 | Zen | text, image, pdf |
| GPT 5 / 5.1 / 5.2 / 5.4 / 5.5 / 5.6 Sol-Terra-Luna (and Codex variants) | Zen | text, image (+pdf on most) |
| Gemini 3 Flash / 3.1 Pro / 3.5-3.7 Flash | Zen | text, image, video, audio, pdf |
| Grok 4.5 / 4.6 | Zen, Go (4.5) | text, image |
| Muse Spark 1.2 | Zen | text, image, video, pdf, audio |
| Kimi K2.5 / K2.6 / K2.7 Code / K3 | Zen, Go | text, image, video |
| Qwen3.5 Plus / 3.6 Plus / 3.7 Plus / 3.8 Max | Zen, Go | text, image, video |
| MiMo-V2.5 | Go | text, image, audio, video |

### ❌ Text-only (no image input)

| Model | Availability |
|-------|---------------|
| GLM-5 / 5.1 / 5.2 / 5.3 | Zen, Go |
| DeepSeek V4 Pro / V4 Flash (incl. Free) | Zen, Go |
| MiniMax M2.5 / M2.7 / M3 (Go) | Zen, Go — note: MiniMax M3 has vision on Zen but **not** on Go |
| Qwen3.7 Max | Zen, Go |
| Hy3 / Hy3 Free | Zen, Go |
| MiMo-V2.5-Pro | Go — note: loses vision that the base MiMo-V2.5 has |
| Big Pickle | Zen |

Verify a specific model's current modalities with `/models` in the TUI, or query `https://models.dev/api.json` directly.

## Setup on a new machine

### 1. Clone the repo

```bash
git clone <repo-url> ~/.config/opencode
```

### 2. Install plugins

`package.json` is gitignored, so create it first:

```json
{
  "dependencies": {
    "@dietrichgebert/ponytail": "^4.9.0",
    "@opencode-ai/plugin": "1.18.4",
    "superpowers": "github:obra/superpowers"
  }
}
```

Then install:

```bash
cd ~/.config/opencode
npm install
```

### 3. Install codebase-memory-mcp

Download the binary from [codebase-memory-mcp releases](https://github.com/nicobailon/codebase-memory-mcp) and install it.

Then **update the binary path** in two places:

**`opencode.jsonc`** — the `command` field:
```jsonc
"command": ["C:/YOUR/PATH/codebase-memory-mcp.exe"]
```

**`plugins/cbm-augment.ts`** — the `BIN` constant:
```ts
const BIN = 'C:/YOUR/PATH/codebase-memory-mcp.exe';
```

### 4. Configure Figma (optional)

Create the `.figma-api-key` file with your Figma personal access token:

```bash
echo "figd_XXXXXXXXXXXXXXXX" > ~/.config/opencode/.figma-api-key
```

Get a token at: **Figma → Settings → Security → Personal access tokens**

If you don't use Figma, disable the server in `opencode.json`:
```json
"figma-xintec": { "enabled": false }
```

### 5. Verify everything works

Open opencode in any project and run `@gato-pm hello` to confirm agents load correctly.

## Gitignored files

The following files are **not tracked** and must be created manually:

| File | Notes |
|------|-------|
| `.figma-api-key` | Your personal Figma API key |
| `node_modules/` | Generated by `npm install` |
| `package.json` | Must be created manually (see step 2 above) |
| `package-lock.json` | Generated by `npm install` |
