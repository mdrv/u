# AGENTS.md

## Overview

This is a personal dotfiles repository (μ - dotfiles) for Arch Linux configurations. The project consists of:

1. **Configuration files** for various tools (nvim, nushell, kitty, hyprland, etc.)
2. **Interactive web site** (SvelteKit) for browsing and understanding the dotfiles
3. **OpenSpec-driven development** workflow for managing changes

## Tech Stack

### Core System

- **Nushell** 0.105.0+ - Primary shell and scripting language
- **Neovim** - Editor with lazy.nvim plugin management

### Web Application

- **SvelteKit** 2.x + **Svelte** 5.x - Web framework
- **TypeScript** 5.x - Type-safe JavaScript
- **Vite** 6.x - Build tool and dev server
- **Bun** - Package manager and runtime for web
- **Vitest** 4.x - Testing framework
- **dprint** - Code formatter
- **shiki** - Syntax highlighting
- **mdsvex** - Markdown support in Svelte

### Development Tools

- **OpenSpec** - Spec-driven development workflow
- **GitHub Actions** - CI/CD for deployment

## Essential Commands

### Web Development (in `web/` directory)

```bash
# Development
bun run dev          # Start dev server on port 3000
bun run d            # Alias for dev

# Building
bun run build        # Production build
bun run b            # Alias for build

# Preview production build
bun run preview
bun run p            # Alias for preview

# Type checking
bun run check        # Run svelte-check with TypeScript
bun run check:watch  # Watch mode for type checking

# Linting and Formatting
bun run lint         # Run prettier and eslint
bun run format       # Run prettier to format files

# Testing
bun run test         # Run vitest tests
```

### OpenSpec Workflow

```bash
# Explore specs and changes
openspec list                  # List active changes
openspec list --specs          # List all specifications
openspec show [item]           # Show details of a change or spec
openspec show [spec] --type spec  # Show a specific spec

# Validation
openspec validate [change-id]              # Validate a change
openspec validate [change-id] --strict --no-interactive  # Strict validation

# Archive completed changes (after deployment)
openspec archive <change-id>              # Interactive archive
openspec archive <change-id> --yes        # Non-interactive archive
openspec archive <change-id> --skip-specs --yes  # Archive without spec updates

# Full-text search across specs
rg -n "Requirement:|Scenario:" openspec/specs
```

### Chezmoi Management

```bash
# Install all or specific configurations
nu install.nu [app_name]

# Add new configs to chezmoi
nu add.nu <path>

# Show managed configs and their status
nu status.nu

# Core chezmoi wrapper commands
nu chezmoi.nu [command]

# Run full migration from symlinks
nu migrate-to-chezmoi.nu

# Available apps:
#   nvim, nushell, kitty, foot, hypr, waybar, dunst, tofi, yazi,
#   zellij, atuin, aichat, fastfetch, home, neovide, opencode, quickshell, otd, keyd
```

### Formatting

```bash
# Format all supported files (dprint)
dprint fmt

# Check formatting
dprint check
```

## Project Structure

```
.
├── web/                    # SvelteKit web application
│   ├── src/
│   │   ├── routes/         # SvelteKit file-based routing
│   │   │   ├── +layout.svelte
│   │   │   ├── +page.svelte
│   │   │   ├── file/[...path]/  # Dynamic file viewer route
│   │   │   └── category/[category]/  # Category listing route
│   │   └── lib/
│   │       ├── components/
│   │       │   ├── CodeViewer.svelte      # Syntax-highlighted code display
│   │       │   └── FileTree.svelte        # File tree navigation
│   │       ├── parsers/
│   │       │   └── AnnotationParser.ts    # Parse annotation comments
│   │       ├── utils/
│   │       │   ├── scanRepo.ts            # Scan and organize repository
│   │       │   └── syntaxHighlighter.ts   # Shiki integration
│   │       └── types.ts                   # TypeScript types
│   ├── static/               # Static assets
│   ├── package.json
│   ├── svelte.config.js      # SvelteKit config (base path: /u)
│   └── vite.config.ts        # Vite config
│
├── nvim/                    # Neovim configuration
│   ├── uinit.lua            # Main entry point
│   ├── utils.lua            # Utility functions
│   ├── ulazy/               # Lazy plugin specs
│   ├── ulsp/                # LSP configurations
│   ├── unavigate/           # Navigation plugin
│   └── README.md            # Installation notes
│
├── nushell/                 # Nushell configurations
│   ├── uinit.nu             # Main config entry point
│   ├── uenv.nu              # Environment setup
│   ├── uconfig.nu           # Config setup
│   └── u/                   # Custom modules
│
├── openspec/                # OpenSpec specification workflow
│   ├── AGENTS.md            # OpenSpec agent instructions
│   ├── project.md           # Project context (template)
│   ├── specs/               # Active specifications (truth)
│   ├── changes/             # Active proposals
│   │   ├── [change-id]/
│   │   │   ├── proposal.md
│   │   │   ├── tasks.md
│   │   │   ├── design.md (optional)
│   │   │   └── specs/       # Delta specs for the change
│   │   └── archive/         # Completed changes
│   └── command/             # OpenSpec CLI commands
│
├── [tool-configs]/          # Individual tool configurations
│   ├── kitty/
│   ├── foot/
│   ├── hypr/
│   ├── waybar/
│   ├── zellij/
│   └── ...
│
├── .opencode/               # OpenCode agent configuration
├── dprint.jsonc            # Formatter configuration
├── symlinks.nu             # Symlink management script
└── u.nu                    # Entry point script
```

## Code Patterns and Conventions

### Annotation Comments

Configuration files can include annotation comments that explain configuration choices. These are parsed by the web application to provide in-context explanations.

**Format:**

- Lua/Nu files: `-- ANNOTATION: explanation` or `# ANNOTATION: explanation`
- Pattern: `/--\s*#?ANNOTATION:\s*(.*)$/i` or `/#\s*ANNOTATION:\s*(.*)$/i`

**Example:**

```lua
-- ANNOTATION: Load device-specific user configuration from .u.lua file
ok, U = pcall(dofile, vim.fs.joinpath(vim.fn.stdpath('config'), '.u.lua'))
```

These annotations are parsed by `web/src/lib/parsers/AnnotationParser.ts` and displayed in the web UI.

### Device-Specific Configurations

**Neovim:** Creates `.u.lua` in the nvim config directory to customize behavior:

```lua
-- Enable plugins by setting LV >= 1
return {
    LV = 1,
}
```

The `uinit.lua` file loads this and uses `U.LV` to control plugin loading.

**Dotfiles:** Add `.u` or `.u.*` files in the same directory for device-specific tweaks.

### Nushell Configuration Architecture

Nushell extends the default configuration by appending a single line:

- In `env.nu`: `source ~/.config/nushell/uenv.nu`
- In `config.nu`: `source ~/.config/nushell/uconfig.nu`

This avoids heavily modifying default configs while adding customization.

### Symlink Management

The `symlinks.nu` script manages symlinking configs to their target locations. Each tool in the `DATA` constant specifies:

- `items`: Files/directories to symlink
- `target`: Target directory (defaults to `~/.config/<app_name>`)
- `message`: Post-link instructions (optional)

### File Categories

The web application categorizes files automatically based on path patterns (see `AnnotationParser.getCategory()`):

- `nvim` - Neovim configs
- `nushell` - Nushell configs
- `terminal` - Terminal emulators (kitty, foot, zellij)
- `compositor` - Compositor (hypr)
- `desktop` - Desktop tools (waybar, dunst, tofi, yazi)
- `system` - System configs (home, etc, fastfetch)
- `theme` - Theme configs (otd)
- `shell` - Shell tools (quickshell)
- `misc` - Everything else

### Code Style

**dprint configuration:**

- **Tabs**: Enabled (useTabs: true)
- **TypeScript**: Single quotes, no semicolons (ASI), prefer single
- **Markup (Svelte)**: Single quotes, indented scripts/styles
- **Lua**: 4-space indentation, force single quotes
- **JSON**: Maintain trailing commas
- **YAML/Markdown/TOML**: Default settings

**Git workflow:**

- Main branch: `main`
- Deploy on push to `main` for web changes
- OpenSpec-based workflow for changes (see below)

## Testing

### Web Application Tests

Tests are located in `web/src/lib/components/CodeViewer.test.js` and use Vitest with jsdom.

**Run tests:**

```bash
cd web
bun run test
```

**Test configuration:**

- Framework: Vitest 4.x
- Environment: jsdom
- Globals: enabled
- Setup files: `src/lib/components/CodeViewer.test.js`

**Test patterns:**

- Mock external dependencies (like Shiki) with `vi.mock()`
- Use `@ts-expect-error` for test infrastructure
- Clean up DOM with `document.body.removeChild(container)`

### Type Checking

```bash
cd web
bun run check           # One-time check
bun run check:watch     # Watch mode
```

## OpenSpec Workflow

This repository uses OpenSpec for spec-driven development. The workflow has three stages:

### Stage 1: Creating Changes

Create a change proposal when:

- Adding features or functionality
- Making breaking changes (API, schema)
- Changing architecture or patterns
- Optimizing performance (changes behavior)
- Updating security patterns

Skip proposal for:

- Bug fixes (restoring intended behavior)
- Typos, formatting, comments
- Dependency updates (non-breaking)
- Configuration changes

**Steps:**

1. Review `openspec/project.md`, `openspec list`, and `openspec list --specs`
2. Choose a unique `change-id` (kebab-case, verb-led: `add-`, `update-`, `remove-`, `refactor-`)
3. Create directory: `openspec/changes/<change-id>/`
4. Write `proposal.md` (why, what changes, impact)
5. Write `tasks.md` (implementation checklist)
6. Write `design.md` (optional, for complex technical decisions)
7. Create spec deltas in `specs/<capability>/spec.md` with `## ADDED|MODIFIED|REMOVED Requirements`
8. Validate: `openspec validate <change-id> --strict --no-interactive`

### Stage 2: Implementing Changes

1. Read `proposal.md`, `design.md` (if exists), and `tasks.md`
2. Implement tasks sequentially
3. Keep changes tightly scoped to the requested outcome
4. After completion, update all tasks to `- [x]` in `tasks.md`

### Stage 3: Archiving Changes

After deployment, create a separate PR to:

1. Move `changes/<id>/` → `changes/archive/YYYY-MM-DD-<id>/`
2. Update `specs/` if capabilities changed
3. Run `openspec archive <change-id> --yes` (or `--skip-specs --yes` for tooling-only changes)
4. Validate: `openspec validate --strict --no-interactive`

**Critical:** Always pass the change ID explicitly to `openspec archive`.

## Important Gotchas

### OpenSpec

- **Scenario formatting**: Must use `#### Scenario:` (4 hashtags, not bullets or bold)
- **MODIFIED requirements**: Always paste the FULL requirement text (scenarios included), not just changes. The archiver replaces the entire requirement.
- **Archive command**: Always specify the change ID explicitly: `openspec archive <change-id> --yes`
- **Validation**: Always use `--strict --no-interactive` for comprehensive validation

### Web Application

- **Base path**: The SvelteKit app is configured with `base: '/u'` for GitHub Pages deployment
- **File routing**: Dynamic routes use `[...path]` for nested file paths
- **Repo root**: The web app expects to be run from the repository root to scan all configs
- **Dependency injection**: Uses Svelte context to pass repoData down the component tree
- **Deployment**: GitHub Actions builds only on changes to `web/**` files

### Neovim

- **Plugin loading**: Controlled by `U.LV` flag from `.u.lua`. Set `LV >= 1` to enable plugins.
- **Lazy.nvim**: Plugins are auto-loaded from `ulazy/` directory on `VimEnter`
- **LSP**: LSP configs in `ulsp/` are auto-loaded; enable with `vim.lsp.enable('<lang>')`
- **Device-specific**: `.u.lua` file in nvim config dir for machine-specific settings

### File System

- **Chezmoi**: Use `nu install.nu <app_name>` to install configs, `nu add.nu <path>` to add new ones
- **Generated files**: Ignore `__gen/`, `.svelte-kit/`, `node_modules/`
- **Config locations**: See `nu status.nu` to show managed configs and their targets
- **Old symlinks**: `symlinks.nu` is preserved for reference during migration

## OpenCode Integration

This repository uses OpenCode for AI agent assistance. Configuration is in `opencode/opencode.jsonc`:

- **Instructions**: Looks for `AGENTS.md` and `packages/*/AGENTS.md`
- **Default agent**: `servant`
- **Formatter**: `dprint` (prettier disabled)
- **Agents**: `servant` (full access), `build` (build-focused), `plan` (planning-only, no write/edit/bash)

## Deployment

The web application is deployed to GitHub Pages via the `.github/workflows/deploy.yml` workflow:

- Triggered on push to `main` branch (when `web/**` files change)
- Uses Bun for installation and build
- Deploys static files from `web/build/` to GitHub Pages
- Base URL: `/u`

## Search and Navigation Patterns

### Finding relevant code

- Use `Glob` for file pattern matching (e.g., `web/**/*.svelte`)
- Use `Grep` for content searching
- Use `Agent` tool for complex, multi-step investigations

### Understanding a feature

1. Check if it has an OpenSpec spec: `openspec list --specs` or `openspec show <spec>`
2. Look for annotation comments in config files
3. Check README files in tool directories
4. Review related test files

## Key Dependencies

### Web Application

- `@sveltejs/adapter-static` - Static site generation for GitHub Pages
- `shiki` - Syntax highlighting
- `mdsvex` - Markdown in Svelte components
- `@testing-library/svelte` - Component testing

### Development

- `dprint` - Multi-language formatter
- `openspec` - Spec-driven development CLI

### System

- Nushell 0.105.0+
- fzf 0.64.0+

## Before Making Changes

1. **Check OpenSpec**: Run `openspec list` to see active changes
2. **Search first**: Look for existing implementations before creating new ones
3. **Read the pattern**: Check similar files for existing conventions
4. **Test after changes**: Run `bun run test` (web) and `openspec validate` (if applicable)
5. **Format**: Run `dprint fmt` to ensure formatting consistency

## Common Tasks

### Adding a new tool config

1. Create directory in repo root with tool name
2. Add config files to the directory
3. Add to chezmoi: `nu add.nu <tool-name>/<path>`
4. Test: `nu install.nu <tool-name>`
5. (Optional) Add annotation comments for documentation
6. If tool has special requirements (e.g., zjstatus.wasm download), add hook to `.chezmoi.post-apply.nu`

### Adding a feature to the web app

1. If significant, create an OpenSpec proposal first
2. Follow SvelteKit file-based routing patterns
3. Use TypeScript types from `web/src/lib/types.ts`
4. Add tests if changing component behavior
5. Run `bun run check` and `bun run test`

### Modifying Neovim config

1. Check `nvim/README.md` for architecture
2. Add new plugin spec to `nvim/ulazy/<plugin-name>.lua`
3. Use lazy plugin pattern with `return { 'user/repo', enabled = true, opts = { ... } }`
4. Configure LSP in `nvim/ulsp/<lang>.lua` if needed
5. Device-specific: add to `.u.lua` in nvim config dir

### Modifying Nushell config

1. Extend `nushell/uenv.nu` for environment variables
2. Extend `nushell/uconfig.nu` for aliases and functions
3. Add custom modules to `nushell/u/` directory
4. Keep changes minimal - the architecture extends defaults rather than replacing them

## Quick Reference

**Start dev server:**

```bash
cd web && bun run dev
```

**Check type errors:**

```bash
cd web && bun run check
```

**Run tests:**

```bash
cd web && bun run test
```

**List OpenSpec changes:**

```bash
openspec list
```

**Install all or specific configs:**

```bash
nu install.nu [app_name]
```

**Add new configs:**

```bash
nu add.nu <path>
```

**Check status:**

```bash
nu status.nu
```

**Run migration:**

```bash
nu migrate-to-chezmoi.nu
```

**Chezmoi commands:**

```bash
nu chezmoi.nu [command]
```

**Check type errors:**

```bash
cd web && bun run check
```

**Format all files:**

```bash
dprint fmt
```
