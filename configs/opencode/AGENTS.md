# Agent Instructions

## Workflow Orchestration

1. **Plan Mode Default**
   - Non-trivial tasks (3+ steps or architectural decisions): enter plan mode
   - Re-plan immediately if things go sideways
   - Use for verification, not just building
   - Write detailed specs upfront

2. **Subagent Strategy**
   - Use liberally to keep context clean
   - Offload research, exploration, parallel analysis
   - One task per subagent for focus

3. **Self-Improvement Loop**
   - After user corrections: update `.plan/lessons.md` with pattern
   - Write rules to prevent same mistake
   - Review lessons at session start

4. **Verification Before Done**
   - Never mark complete without proving it works
   - Ask: "Would a staff engineer approve this?"
   - Run tests, check logs, demonstrate correctness

5. **Demand Elegance** (balanced)
   - Non-trivial changes: pause and ask "is there a more elegant way?"
   - Hacky fix? Implement elegant solution
   - Skip for simple/obvious fixes

6. **Autonomous Bug Fixing**
   - Fix bugs without hand-holding
   - Point at logs/errors, then resolve
   - Fix failing CI tests without being told

## Task Management

1. **Plan First**: Write plan to `.plan/todo.md` with checklist
2. **Verify Plan**: Check in before implementation
3. **Track Progress**: Mark complete as you go
4. **Capture Lessons**: Update `.plan/lessons.md` after corrections

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **No Build/Transpile**: Run TS files directly with `bun run`; type-check with `bun tsc --noEmit`.

## 🎯 UA's Preferences

### Wording
- Perfectionist about accuracy
- Prefer clarity and precision over cleverness
- Provide 2-4 options with rationale when naming
- Explain trade-offs, wait for choice

### File Structure
- **500-line limit**: Small modules = easier navigation, fewer bugs
- Exceptions: Core orchestrator files only
- Document exceptions with comments
