## Mandatory Code Exploration Rules

1. **Skill Auto-Activation**: For ANY query related to code, structure, functions, errors, or project architecture, you MUST immediately execute `skill({ name: "codebase-memory" })` or use the `codebase-memory-mcp` MCP server tools directly.
2. **Auto-Index & Self-Healing (CRITICAL)**: Before querying the knowledge graph, verify the project status. If `index_status` or any graph tool returns an error such as `"project not found or not indexed"` (which happens when folders are renamed or moved), you MUST IMMEDIATELY execute `index_repository(repo_path=".", mode="moderate")` to index the current workspace under its new path before attempting any graph search.
   - **Keep the index fresh (CRITICAL)**: Before relying on graph results, run `detect_changes`. If `changed_files` is non-empty, re-index with `index_repository(repo_path=".", mode="moderate")` first. Re-index at the start of code work on a project and after making code edits before querying the graph about that code.
   - **Keep `.codebase-memory/` out of git**: When indexing a repo, verify with `git check-ignore .codebase-memory/`; if not ignored, append `.codebase-memory/` to `.git/info/exclude`. Full workflow in the `codebase-memory` skill.
3. **Priority over File Search**: NEVER use `grep`, `glob`, or read source files directly as a first step. Always query the knowledge graph first using `search_graph`, `trace_path`, or `get_architecture`.

## Command Execution & Security Protocol

4. **Pre-Execution Justification**: Before invoking ANY terminal/bash command or script, you MUST first output a brief 1-line text message explaining WHAT the command does and WHY it is necessary for the current step.
5. **Git Diff Syntax**: When comparing branches with `git diff`, ALWAYS use space separation (e.g., `git diff branchA branchB -- file`) instead of dot notation (`branchA..branchB`). Never use `..` in terminal arguments to avoid triggering security path-traversal filters.