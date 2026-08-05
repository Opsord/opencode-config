---
name: codebase-memory
description: REQUIRED: Automatically load this skill for ANY request involving code analysis, searching functions or classes, exploring architecture, tracing calls, or inspecting the codebase.
---

# Codebase Knowledge Graph (codebase-memory-mcp)

This project uses `codebase-memory-mcp` to maintain a persistent knowledge graph of the codebase. ALWAYS prefer MCP graph tools over grep/glob/file-search for code discovery.

## 0. Pre-requisite (On-Demand Indexing)
- Always verify index status using `index_status` or run `index_repository(repo_path=".")` when starting code exploration on an unindexed project.

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
- Index current project: `index_repository(repo_path=".")`
- Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
- Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
- Read source code: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`