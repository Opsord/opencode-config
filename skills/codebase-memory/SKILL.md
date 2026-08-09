---
name: codebase-memory
description: REQUIRED: Automatically load this skill for ANY request involving code analysis, searching functions or classes, exploring architecture, tracing calls, inspecting the codebase, or keeping the code index fresh (e.g. after code changes, git pull, or merge).
---

# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses `codebase-memory-mcp` to maintain a persistent knowledge graph of the codebase. ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## 0. Pre-requisite (On-Demand Indexing)
- Always verify index status using `index_status` or run `index_repository(repo_path=".", mode="moderate")` when starting code exploration on an unindexed project.

## Index Freshness (Re-Index on Change)
The knowledge graph goes stale whenever the code changes. Before trusting graph results for a project:

1. Check freshness with `detect_changes(project="<name>")` (cheap git diff from the last indexed commit to HEAD).
   - `changed_files` empty → index is fresh, proceed.
   - `changed_files` non-empty → index is stale.
2. If stale, re-index: `index_repository(repo_path=".", mode="moderate")`, then continue.

Re-index in these situations:
- At the start of any code work on an indexed project (covers git pull, changes made by other tools, or previous sessions).
- After making code edits in this session, before querying the graph about the edited code (re-index once per completed task, not after every single edit).

Note: `detect_changes` is nearly free — always use it instead of re-indexing blindly.

## Keep `.codebase-memory/` Out of Git
`.codebase-memory/` holds index artifacts and must never be committed.

- When starting to index a repo, verify it is ignored: `git check-ignore .codebase-memory/`
- If not ignored, append `.codebase-memory/` to the repo-local exclude file (`.git/info/exclude`) — this does not touch `.gitignore` or history.
- A global `core.excludesFile` should already cover all repos on this machine; the per-repo check is a safety net for repos that don't inherit it.

## Priority Order
1. `index_repository` / `index_status` — Verify or initialize graph index when needed
2. `search_graph` — Find functions, classes, routes, or variables by pattern
3. `trace_path` — Trace function callers (inbound) or callees (outbound)
4. `get_code_snippet` — Read specific function/class source code
5. `query_graph` — Run Cypher queries for complex structural patterns
6. `get_architecture` — High-level project summary and boundary mapping

## When to fall back to grep/glob
- Searching for exact string literals, error messages, or config key values
- Searching non-code files (Dockerfiles, shell scripts, raw configs)
- When MCP graph tools return insufficient or empty results

## Examples
- Index current project: `index_repository(repo_path=".", mode="moderate")`
- Check freshness: `detect_changes(project="<project-name>")`
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source code: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`