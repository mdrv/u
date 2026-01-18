# Dotfiles Site

This is a SvelteKit static site for displaying Arch Linux dotfiles with interactive annotations.

## Development

```bash
bun install
bun run dev
```

## Build

```bash
bun run build
bun run preview
```

## Features

- Interactive code viewer with syntax highlighting
- Inline annotations with markdown support
- File tree navigation
- Category-based filtering
- Search and sorting

## Annotation Syntax

Add annotations to your config files using the following syntax:

For Lua:
```lua
-- ANNOTATION: This disables Python 3 provider
g.loaded_python3_provider = 0
```

For Nushell/Shell:
```nu
# ANNOTATION: Custom prompt with git info
def prompt [] { ... }
```

For config files:
```conf
# ANNOTATION: Set font size
font_size 12
```
