## Mandatory Code Exploration Rules

<!-- codebase-memory-mcp:start -->
# Codebase Memory

This project uses codebase-memory-mcp to maintain a knowledge graph of the codebase.

### 1. Skill Auto-Activation
For ANY query related to code, structure, functions, errors, or project architecture, you MUST immediately execute `skill({ name: "codebase-memory" })` or use the `codebase-memory-mcp` MCP server tools directly.

### 2. Auto-Index & Self-Healing (CRITICAL)
Before querying the knowledge graph, verify the project status. If `index_status` or any graph tool returns an error such as `"project not found or not indexed"` (which happens when folders are renamed or moved), you MUST IMMEDIATELY execute `index_repository(repo_path=".", mode="moderate")` to index the current workspace under its new path before attempting any graph search.
- **Keep the index fresh (CRITICAL)**: Before relying on graph results, run `detect_changes`. If `changed_files` is non-empty, re-index with `index_repository(repo_path=".", mode="moderate")` first. Re-index at the start of code work on a project and after making code edits before querying the graph about that code.
- **Keep `.codebase-memory/` out of git**: When indexing a repo, verify with `git check-ignore .codebase-memory/`; if not ignored, append `.codebase-memory/` to `.git/info/exclude`. Full workflow in the `codebase-memory` skill.

### 3. Priority over File Search
NEVER use `grep`, `glob`, or read source files directly as a first step. Always query the knowledge graph first using `search_graph`, `trace_path`, or `get_architecture`.

#### Tool Priority Order
1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `check_index_coverage` — validate candidate paths and missed ranges before claims
5. `query_graph` — run Cypher queries for complex patterns
6. `get_architecture` — high-level project summary

#### When to fall back to grep/glob
- Searching for string literals, error messages, config values
- Searching non-code files (Dockerfiles, shell scripts, configs)
- When MCP tools return insufficient results

#### Examples
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`

### Evidence Tiers
- **Scout (Tier 1):** quick positive lookup with few calls and targeted source checks. Mark it provisional; do not make negative or exhaustive claims.
- **Verify (Tier 2, default):** task-directed graph evidence, relevant trace directions, exact snippets for material claims, and relevant pagination.
- **Auditor (Tier 3):** bounded-scope full verification with current generation, complete relevant pagination, both call directions and broader relationships when material, and every limitation disclosed.
- After candidate paths are known in any tier, call `check_index_coverage` once with every evidence path. Add relevant scopes for negative or exhaustive claims. A clean result means no recorded gap, not proof of completeness. For partial, skipped, excluded, stale, pending, or unknown coverage, read/grep the reported ranges or scope before relying on graph results.

### Session Resets & Subagents
- At session start or after compaction, confirm the nearest graph project and generation with `list_projects` or `index_status`, then choose Scout, Verify, or Auditor.
- Before spawning a subagent, query the graph and coverage in the parent. Pass the tier, project, generation/freshness, bounded scope, queries and pagination state, qualified symbols, paths, call-chain findings, coverage evidence with ranges/reasons, source fallback already performed, and unresolved questions in the delegated task context.
- Do not assume subagents inherit MCP access or the parent conversation. If a child lacks MCP tools, it must not call or claim MCP access. It should use the supplied evidence and read/grep exact source, especially every reported missed-coverage range.
<!-- codebase-memory-mcp:end -->

## Command Execution & Security Protocol

4. **Pre-Execution Justification**: Before invoking ANY terminal/bash command or script, you MUST first output a brief 1-line text message explaining WHAT the command does and WHY it is necessary for the current step.
5. **Git Diff Syntax**: When comparing branches with `git diff`, ALWAYS use space separation (e.g., `git diff branchA branchB -- file`) instead of dot notation (`branchA..branchB`). Never use `..` in terminal arguments to avoid triggering security path-traversal filters.

<!-- context7 -->
Use the `ctx7` CLI to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service — even well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This includes API syntax, configuration, version migration, library-specific debugging, setup instructions, and CLI tool usage. Use even when you think you know the answer — your training data may not reflect recent changes. Prefer this over web search for library docs.

Do not use for: refactoring, writing scripts from scratch, debugging business logic, code review, or general programming concepts.

## Steps

1. Resolve library: `npx ctx7@latest library <name> "<what to look up>"` — use the official library name with proper punctuation (e.g., "Next.js" not "nextjs", "Customer.io" not "customerio", "Three.js" not "threejs")
2. Pick the best match (ID format: `/org/project`) by: exact name match, description relevance, code snippet count, source reputation (High/Medium preferred), and benchmark score (higher is better). If results don't look right, try alternate names or queries (e.g., "next.js" not "nextjs", or rephrase the question)
3. Fetch docs: `npx ctx7@latest docs <libraryId> "<what to look up>"` — run a separate `docs` command per distinct concept if the question spans multiple topics, unless it's about how they interact
4. Answer using the fetched documentation

You MUST call `library` first to get a valid ID unless the user provides one directly in `/org/project` format. Be specific about what to look up in the library's documentation — specific and detailed queries return better results than vague single words, but keep each query to a single concept unless the question is about how concepts interact; combined multi-topic queries dilute ranking and return shallow results for each topic. Do not run more than 3 commands per question. Do not include sensitive information (API keys, passwords, credentials) in queries.

For version-specific docs, use `/org/project/version` from the `library` output (e.g., `/vercel/next.js/v14.3.0`).

If a command fails with a quota error, inform the user and suggest `npx ctx7@latest login` or setting `CONTEXT7_API_KEY` env var for higher limits. Do not silently fall back to training data.
<!-- context7 -->

## Process Discipline

Use the superpowers / ponytail skill workflows when they apply:

- **Features / creative work**: invoke brainstorming first, or `@gato-pm` when the user wants an explicit plan.
- **Skip `@gato-pm`**: single-file bugfixes, typos, one-liner config, or when the user already provided a clear checklist — go straight to `@hormiga-dev`.
- **Multi-step implementation**: write (or consume) a plan artifact under `docs/plans/<slug>.md` before editing code; then `@hormiga-dev` implements from that file. `@pato-poderoso` only when the user asks for broad autonomy or heavy/install-heavy ops.
- **Bugs**: use systematic-debugging before proposing a fix.
- **Before claiming done / fixed / passing**: run verification-before-completion with real build/lint/test evidence. Do not assert success without it. `@hormiga-dev` should invoke `@raton-auditor` on the diff before final handoff.
- Prefer minimal diffs (ponytail / YAGNI) unless the brief requires otherwise.
- Stay inside OpenCode agents/skills; do not dispatch external agent CLIs (agy, Orca workers, etc.) from this config.

## Bash hygiene (fewer permission prompts)

- Prefer built-in tools (`grep`, `glob`, `read`, codebase-memory) over shell search when enough.
- **One shell command per bash call.** Do not chain with `;`, `&&`, `|`, or newlines in a single bash invocation (e.g. avoid `git status; git log`). Run separate calls instead — compound strings miss allowlist patterns and fall through to ask.
- Safe read searches via shell are allowlisted (`rg *`, `grep *`, git status/diff/log/…). Mutating git, installs, and destructive ops stay ask/deny as configured.
