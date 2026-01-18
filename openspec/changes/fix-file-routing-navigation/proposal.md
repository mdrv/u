# Change: Fix SvelteKit file routing and navigation

## Why

File links throughout the SvelteKit site were broken, returning 404 errors when navigating to individual file pages (e.g., `/u/file/nushell/u/arch.nu`). The route parameter `[path]` could not handle paths containing slashes.

## What Changes

- Changed route from `[path]` to `[...path]` to support multi-segment file paths
- Updated all navigation links to use `resolve('/file/[...path]', { path })` with proper base path handling
- Fixed FileTree component recursion by removing deprecated `<svelte:component>` and using direct component import
- Removed unused `Self.svelte` wrapper component
- Fixed TypeScript errors (added type annotations)
- Removed unused CSS selectors

## Impact

- Affected code: `/web/src/routes/file/[path]/` → `/web/src/routes/file/[...path]/`
- Affected files: `+page.svelte`, `+page.server.ts`, `FileTree.svelte`, all route files with file links
- Type: Bug fix (restore intended routing behavior)
