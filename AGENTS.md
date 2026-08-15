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
