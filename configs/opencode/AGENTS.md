# Agent Instructions

## FIRST: Check Engram

Before starting any task, call `engram_mem_search` with `scope="personal"` to check for UA's preferences, patterns, and prior decisions.

## When to Save

Call `mem_save` proactively after significant work:

| When                  | Type        | Example Title                        |
| --------------------- | ----------- | ------------------------------------ |
| Bug fix               | `bugfix`    | "Fixed N+1 query in UserList"        |
| Architecture decision | `decision`  | "Chose Zustand over Redux"           |
| Pattern established   | `pattern`   | "Repository pattern for data access" |
| Config change         | `config`    | "Switched to pnpm workspace"         |
| Discovery/gotcha      | `discovery` | "FTS5 MATCH needs quoted terms"      |

**Format:**

```
**What**: One sentence
**Why**: Reasoning or motivation
**Where**: Files/paths affected
**Learned**: Gotchas or edge cases (optional)
```

## When to Search

- **Proactive:** At session start for UA preferences (`scope="personal"`)
- **Reactive:** User says "remember", "recall", "what did we do"
- **Before decisions:** Starting work that might overlap past sessions

## Session Protocol

1. **Start:** `mem_session_start` with project name
2. **During:** Save observations proactively (see above)
3. **End:** `mem_session_summary` with Goal/Discoveries/Accomplished/Files — mandatory

## Scope Usage

- `scope="personal"` — UA preferences and cross-project patterns
- `scope="project"` (default) — Codebase-specific memories

## Efficient Retrieval

Use progressive disclosure to save tokens:

1. `mem_search` → Get relevant observation IDs
2. `mem_timeline` → Chronological context around specific observation
3. `mem_get_observation` → Full untruncated content only when needed
