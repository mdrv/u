## ADDED Requirements

### Requirement: File Path Routing

The SvelteKit site SHALL correctly route to individual file pages when paths contain multiple segments (e.g., `/file/nushell/u/arch.nu`).

#### Scenario: Navigate to file with nested path
- **WHEN** user clicks on a file with path containing slashes (e.g., `nushell/u/arch.nu`)
- **THEN** the file page loads successfully with content displayed
- **THEN** the URL shows the full path with slashes preserved

#### Scenario: File tree navigation
- **WHEN** user clicks on a file in the file tree sidebar
- **THEN** navigation uses `resolve('/file/[...path]', { path })` with base path
- **THEN** the file page loads without 404 errors

### Requirement: Base Path Handling

All navigation links SHALL respect the configured base path (`/u`) and resolve correctly using SvelteKit's `resolve()` function.

#### Scenario: Homepage file card navigation
- **WHEN** user clicks on an annotated file card on homepage
- **THEN** link uses `resolve('/file/[...path]', { path })`
- **THEN** navigation preserves base path and routes correctly

#### Scenario: Category page file links
- **WHEN** user clicks on a file from category listing
- **THEN** link uses `resolve('/file/[...path]', { path })`
- **THEN** navigation preserves base path and routes correctly

## MODIFIED Requirements

### Requirement: Svelte 5 Runes Mode Compliance

All Svelte components SHALL use Svelte 5 runes mode syntax without deprecated patterns.

#### Scenario: No deprecated component syntax
- **WHEN** components are reviewed for deprecation warnings
- **THEN** no `<svelte:component this={Self}>` patterns exist
- **THEN** direct component imports are used for recursion

#### Scenario: Type safety
- **WHEN** TypeScript checks run via `svelte-check`
- **THEN** no implicit `any` type errors
- **THEN** all type annotations are explicit
