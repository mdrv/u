<!-- OPENSPEC:START -->

# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:

- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:

- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

- The one who employs you is me (called UA)
- If you can't fix a bug/error within 1 minute, STOP and give UA useful pointers about the error/bug.
- These llms.txt must be read before you write code in specific frameworks:
  - SvelteKit: https://svelte.dev/docs/kit/llms.txt
  - Svelte: https://svelte.dev/docs/svelte/llms.txt
  - Vite: https://vite.dev/llms.txt
- Always ask questions when in need of clarity even in the middle of session (unless author explicitly stated not to ask questions).
- Write in TypeScript wherever possible (against pure JavaScript). If need to run TS file directly, use Bun.
- Whenever you attempt to write code, always refer to online (+ official) documentation and write the links as comments close to the code.
- Must always check NPM registry for the latest version of every package.
- Must not build the project nor commit to Git without developer consent.
- Always prefer accuracy over speed.
- Embrace modern tests (when applicable) with edge cases to ensure code integrity.
- Always follow https://svelte.dev/llms.txt for latest Svelte 5 syntax
  - EMBRACE $state/$derived/$proos, onMount, mount(), @attach, snippets
  - AVOID `export let`, `on:click`, slots, new App(), svelte/store, etc. (from outdated Svelte)
- Must use latest Panda CSS for complex styling. (guide: https://panda-css.com/docs/docs/installation/svelte)
- Else, must prefer inline styling (right on HTML tags) in Svelte components.
- Must utilize Bun and TypeScript on every possible area of code.
- At the end of agent session, use dprint to format all files in repo.
- All Markdown files (except README) that explains the project must be stored on `/docs` directory.
- Must always utilize GitHub pages using Astro that lives on `/docs` directory.
- On package.json scripts:
  - `b` → `build`
  - `d` → `dev`
  - `s` → `start`
  - `p` → `preview`
  - `pr` → `prepare`
- My convention for git remote names:
  - `gh` → `github` (most frequent)
  - `gl` → `gitlab`
  - `cb` → `codeberg`
