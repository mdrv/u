# Agent Instructions

## Workflow Orchestration

1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately – don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

3. Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons .md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes – don't over-engineer
- Challenge your own work before presenting it

6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests – then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

Task Management

1. **Plan First**: Write plan to `tasks/todo .md` with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to `tasks/todo .md`
6. **Capture Lessons**: Update `tasks/lessons .md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **No Build/Transpile**: ❌ NEVER run `bun build` or transpile TypeScript to JavaScript. Run TS files directly with `bun run` or `bun x`. JS files become stale and cause confusion.

## 🧠 Memory Protocol (OUTDATED, memory-mcp deleted)

Two memory systems via MCP:

- **MegaMemory** — Concepts, decisions, patterns (global)
- **memory-mcp** — Code indexing, symbol search (projects isolated by project_id)

### Workflow

**Session Start:**

```
megamemory:list_roots → megamemory:understand("development principles") → memory_mcp:get_status
```

**Before Task:** `megamemory:understand({ query, top_k: 10 })` + `memory_mcp:recall_code` (if code needed)

**After Task:** `megamemory:create_concept` → Triple sync (MegaMemory + Files + Git)

### Decision Matrix

| Need                   | Tool       | MegaMemory Concept              |
| ---------------------- | ---------- | ------------------------------- |
| Architecture/decisions | MegaMemory | `understand("architecture")`    |
| Dev preferences        | MegaMemory | `understand("developer")`       |
| Find function/code     | memory-mcp | `recall_code`, `search_symbols` |
| Call graph             | memory-mcp | `get_callers`, `get_callees`    |
| Tool parameters        | —          | `CONCEPT: memory-mcp Tools`     |
| RRF tuning             | —          | `CONCEPT: RRF Weights`          |

### Rules

1. ✅ `megamemory:understand` BEFORE any task
2. ✅ memory-mcp for CODE, MegaMemory for CONCEPTS
3. ✅ Store dev preferences as `decision` kind
4. ✅ Triple sync after completion
5. ❌ NEVER store code in MegaMemory
6. ❌ NEVER store concepts in memory-mcp

**Concept kinds:** `feature` | `module` | `pattern` | `config` | `decision` | `component`

### memory-mcp Ignore Requirements

**CRITICAL:** Create `.gitignore` OR `.memoryignore` BEFORE indexing a project with memory-mcp to prevent unnecessary files (ex. node_modules).

```
memory-mcp:index_project /path/to/project
```

## 📋 Task Ledger Workflow

**Decision:** Drop OpenSpec entirely. Use MegaMemory as task ledger with zero ceremony.

### Status Prefix Convention

Use status prefixes in concept `summary` field for task state:

| Prefix | Meaning | When Used |
|--------|----------|-----------|
| `[TODO]` | Not started | New task, ready to pick up |
| `[WIP]` | In progress | Currently working, mid-session |
| `[DONE]` | Complete | Archived, can be referenced |

**Examples:**
```
[TODO] Implement auth middleware - needs JWT validation
[WIP] Refactor DB layer - schema done, queries pending
[DONE] Setup SurrealDB connection - live in src/db/client.ts
```

### Per-Project Task Organization

Create parent concept per project:
```
Project: pb26 (high school website)
├── [TODO] Add dark mode toggle
├── [WIP] Fix login redirect bug
└── [DONE] Setup SvelteKit structure

Project: surrealhub (SurrealDB sync system)
├── [WIP] Implement conflict resolution
└── [TODO] Add real-time sync status
```

Use `parent_id` when creating child tasks via `megamemory:create_concept`.

### Session Start Pattern

AI agents at session start:

```
megamemory:list_roots → megamemory:understand("TODO WIP <project>")
```

This surfaces all pending work across all projects instantly.

### Brainstorming Pattern

Replace `/opsx:explore` with natural language session:

**User:** "Let's explore X. Don't implement yet — brainstorm options."
**AI:** [analyzes options, discusses trade-offs]
**User:** "Capture that decision."
**AI:** `megamemory:create_concept(kind: "decision", summary: "...")`

No markdown artifacts. No folders. Just concepts.

### During Work

When task state changes:
```js
megamemory:update_concept(
  id: "task-id",
  changes: { summary: "[DONE] Implement auth middleware" }
)
```

Update `file_refs` when code is written: add paths to track what was implemented.

### Why This Works

- **Zero ceremony** — one concept update per task
- **Cross-session persistence** — MegaMemory survives AI context loss
- **Searchable** — query by status (`"TODO"`) or project
- **Auditable** — `[DONE]` tasks with `file_refs` show what shipped
- **No anti-pattern** — eliminates "OpenSpec without spec-driven schema" issue

**Related concept:** `CONCEPT: Workflow: Task Ledger via MegaMemory`

## 🎯 UA's Preferences

### Naming Conventions

**Decision-making approach:**
- Ask AI for multiple naming options before choosing
- Evaluate how names "stick" after sessions
- Drop/replace names that don't work
- Capture final naming decision as `decision` kind in MegaMemory

**Example process:**
```
UA: "What are good names for this feature?"
AI: "Options: 'TaskStream', 'WorkQueue', 'TaskLedger'..."
UA: "I like TaskLedger — it feels right"
AI: megamemory:create_concept(kind: "decision", summary: "Naming: TaskLedger for task tracking system")
```

### Wording & Documentation

**UA's self-assessment:**
- Not a professional writer
- Perfectionist about wording accuracy
- Wrong wording bothers UA and creates cognitive friction
- Prefers clarity and precision over cleverness

**When naming or wording:**
1. Provide 2-4 options with rationale
2. Explain trade-offs (e.g., clarity vs brevity)
3. Wait for UA's choice before committing
4. If UA asks for refinement, iterate without judgment

**Examples of UA's style:**
- Precise: "Task Ledger via MegaMemory" (not "Task Management System")
- Direct: "Drop OpenSpec" (not "Consider deprecating OpenSpec")
- Concise: Status prefixes `[TODO]`, `[WIP]`, `[DONE]` (not verbose descriptions)

### File Size and Structure

**Rationale for 500-line limit:**
- **Flashcard approach** — Small, focused modules are easier to understand and navigate
- **Error prevention** — AI edits on smaller files are less prone to introducing bugs
- **Cognitive load** — Smaller files reduce mental overhead when jumping between modules

**Exceptions:**
- Core orchestrator files may exceed 500 lines (navigation convenience)
- All other modules/files must stay under 500 lines
- Document exceptions with comments explaining trade-off

**Related concept:** `CONCEPT: Dotfiles Structure Decision`

**Related concept:** `CONCEPT: Developer: UA-sensei`

## Delegation Protocol

Before delegating coding tasks to specialists (@fixer, @designer, @coder):

```
megamemory:understand("development principles") → Pass summary in prompt
```

Specialists must follow: Bun runtime, dprint formatter, type safety, no `any`, max 500 lines/file, NO build/transpile to JS.

---

**Detailed docs:** `megamemory:understand("memory-mcp tools RRF weights triple sync")`

## 🔍 Search Tools Priority

| Need                 | Tool            | Notes                                               |
| -------------------- | --------------- | --------------------------------------------------- |
| Code in project      | memory-mcp      | `recall_code`, `search_symbols`                     |
| Library docs         | context7 or exa | context7 for official docs, exa for broader context |
| Web search           | searxng → exa   | searxng (free), exa as fallback                     |
| GitHub code examples | grep_app        | Real-world code patterns                            |

---

## Tool References

**High-frequency development tools** — See `CONCEPT: Development Tools Stack`

| Tool | Docs | CLI Help |
|-------|-------|-----------|
| **Zellij** | `CONCEPT: Zellij Documentation` | `zellij --help` |
| **OpenCode** | https://open-code.ai | `opencode --help` |
| **Neovim** | https://neovim.io/doc | `:help vim.keymap.set`, `:help vim.lsp.config` |
| **Hyprland** | https://hypr.land/ | CLI: `hyprctl version` |
| **Bun** | https://bun.sh | `bun help <command>` |
| **ElysiaJS** | https://elysiajs.com | `:help Elysia.t` |
| **Nushell** | https://www.nushell.sh | `help <command>` |

**Creativity tools** — See `CONCEPT: Creativity Tools Stack`

| Tool | Docs |
|-------|------|
| **Krita** | docs.krita.org |
| **Inkscape** | inkscape.org |
| **Ardour** | ardour.org |
| **Tenacity** | audacityteam.org |
| **Blender** | docs.blender.org |

**Separated stacks** — Creativity tools reduce convolution when querying `development principles`.

## 🎨 Svelte Development

- Use `svelte_svelte-autofixer` before returning Svelte code
- Use `svelte_list-sections` then `svelte_get-documentation` for Svelte 5/SvelteKit docs
- Offer playground link via `svelte_playground-link` for code snippets (ask first)

## Browser Automation

Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

Core workflow:

1. `agent-browser open <url>` - Navigate to page
2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
4. Re-snapshot after page changes

Note: playwright-cli could also be alternative.
