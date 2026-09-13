# opencode global config (OpenCode 2)

Native [OpenCode 2](https://opencode.ai/v2/docs/migrate-v1/) configuration stored at `~/.config/opencode/`. The OpenCode 1.x snapshot is on branch `opencode-v1`.

## File structure

```
~/.config/opencode/
├── opencode.jsonc           # Main config: permissions, plugins, MCP, default agent
├── cli.json                 # Terminal client config (global, v2)
├── AGENTS.md                # Global system prompt (graph-first, ctx7, process)
├── package.json             # Plugin dependencies
├── pnpm-lock.yaml           # Lock file
├── node_modules/            # Installed plugins (gitignored)
├── agents/                  # Custom agent definitions (v1 frontmatter; v2 translates it)
│   ├── gato-pm.md           # Technical PM: plans features, generates checklists
│   ├── hormiga-dev.md       # Senior dev (default_agent): executes plans
│   ├── raton-auditor.md     # Auditor: quality, security, YAGNI (subagent)
│   ├── cuervo-pensador.md   # opencode config specialist
│   ├── pato-poderoso.md     # Heavy-duty execution agent (broad permissions)
│   ├── codebase-memory.md   # Graph lookup Tier 2 (subagent)
│   ├── codebase-memory-auditor.md  # Graph audit Tier 3 (subagent)
│   └── codebase-memory-scout.md   # Fast graph lookup Tier 1 (subagent)
├── skills/
│   └── codebase-memory/
│       └── SKILL.md         # Knowledge-graph skill
├── plugins/
│   └── cbm-augment.ts       # Plugin: enriches grep/glob results with graph context
└── .keys/                   # API keys (gitignored)
```

## Installed plugins

| Plugin | Version | Description |
|--------|---------|-------------|
| `superpowers` | github:obra/superpowers | Process skills: brainstorming, TDD, systematic debugging, verification |
| `@dietrichgebert/ponytail` | ^4.9.0 | YAGNI / minimal diffs |
| `@opencode/plugin` | ^2.0.0 | OpenCode 2 plugin SDK (required by local plugins) |
| `codebase-memory-augment` | local | `plugins/cbm-augment.ts` — graph context after grep/glob |

`superpowers` and `ponytail` still ship V1 plugin entrypoints. V2 does not run V1 plugin implementations; if `opencode plugin list` omits them, their auto-injected skills/hooks will not load until those packages publish a V2 `Plugin.define` export. The local `cbm-augment` plugin is already on the V2 API.

## Global skills

| Skill | Location | Scope |
|-------|----------|-------|
| `codebase-memory` | `skills/codebase-memory/` | Global — structural code queries |
| superpowers / ponytail skills | via `plugins` | Global — process & minimalism (depends on those packages loading) |

### Shared hub (`~/.agents/skills`)

Optional cross-runtime skills (not required for this OpenCode-only workflow):

| Skill | Role |
|-------|------|
| `codebase-memory` | Knowledge-graph workflows (also mirrored under `skills/` above) |
| `find-docs` | Current library docs via Context7 CLI |
| `impeccable` | Frontend craft / UI critique |

**Project-only (not in this global config):** Stitch, Playwright, and similar domain skills under a project's `.opencode/skills/` or `.agents/skills/` when needed.

### Global vs project

| Keep global / hub | Put on the project |
|-------------------|--------------------|
| `codebase-memory`, superpowers, ponytail, `find-docs`, `impeccable` | Stitch, Playwright, Figma-heavy workflows, product-specific skills |

## MCP servers

Configured under `mcp.servers` in `opencode.jsonc` (`disabled: false` to enable).

| Server | Enabled | Description |
|--------|---------|-------------|
| `codebase-memory-mcp` | yes | Knowledge graph |
| `figma-xintec` | no | Figma via `figma-developer-mcp` |
| `stitch-cargoability` | no | Stitch MCP (enable in a Stitch project if needed) |
| `stitch-personal` | no | Stitch MCP (enable in a Stitch project if needed) |

## Agents

Built-in OpenCode agents **`plan`** and **`build`** are disabled. Default primary agent: **`hormiga-dev`**.

| Agent | Mode | Role |
|-------|------|------|
| `@hormiga-dev` | primary (default) | Executes plans: implements checklists with verification before "done" |
| `@gato-pm` | primary | Plans features → writes `docs/plans/<slug>.md` |
| `@pato-poderoso` | primary | Heavy-duty execution with broad bash autonomy |
| `@cuervo-pensador` | primary | Audits/optimizes this opencode config |
| `@raton-auditor` | subagent | Audits changes: security, architecture, performance, YAGNI |
| `@codebase-memory` | subagent | Graph lookup Tier 2 |
| `@codebase-memory-auditor` | subagent | Graph audit Tier 3 |
| `@codebase-memory-scout` | subagent | Graph lookup Tier 1 |

**Daily loop (OpenCode only):** small fixes → `@hormiga-dev`; features → `@gato-pm` (`docs/plans/`, gitignored) → `@hormiga-dev` → `@raton-auditor`. Use `@pato-poderoso` only when explicitly requested for broad/heavy autonomy.

Permissions in `opencode.jsonc` are an ordered v2 array (last matching rule wins: broad rules first, exceptions after). Agent markdown still uses v1 `permission` / `bash` frontmatter; OpenCode 2 translates it.

## Model vision support (OpenCode Zen / Go)

_Last updated: 2026-08-16 — source: [models.dev](https://models.dev/api.json)._

Needed for `impeccable`'s `live` (annotated screenshots) and `critique`/`audit` (visual inspection) flows. Re-check `models.dev` before trusting this table long-term — providers add/drop image support between releases.

### Vision-capable (accepts images)

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

### Text-only (no image input)

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

```bash
cd ~/.config/opencode
pnpm install
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
const BIN = process.env.CBM_BIN ?? 'C:/YOUR/PATH/codebase-memory-mcp.exe';
```

### 4. Configure Figma / Stitch keys (optional)

Keys live under `.keys/` (or legacy `.figma-api-key`). MCP entries for Figma and Stitch stay in `opencode.jsonc` with `"disabled": true` until you turn them on for a project that needs them.

### 5. Verify

Open opencode and confirm default agent is `hormiga-dev`, built-in `plan`/`build` are gone from Tab, and `@gato-pm` / `@hormiga-dev` load. Run `opencode plugin list`: `codebase-memory-augment` should appear as `local`. `superpowers` and `ponytail` may show with empty ID until those packages ship V2 entrypoints.

## Gitignored files

| File | Notes |
|------|-------|
| `.keys/` / `.figma-api-key` | API keys |
| `node_modules/` | From `pnpm install` |
| `package-lock.json` | npm lock; this repo uses pnpm |
| `service.json` | Local OpenCode service state |
| `*.bak` | Local backups |
| `docs/plans/` | Gato PM implementation plans |
