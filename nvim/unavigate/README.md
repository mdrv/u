# unavigate.nvim

Future-proof file navigation for Neovim using pattern-based search instead of fragile line numbers.

## Features

- Navigate to files using `#pattern` syntax instead of line numbers
- Support for your existing `id=` tag system
- Integrated with fzf-lua for searching all ID tags
- Works with multiple comment styles (`--`, `//`, `#`)
- Fallback support for traditional `:line` and plain file paths

## Supported Patterns

### 1. ID-based navigation (recommended)

```lua
-- See nvim/uinit.lua#id=keymaps
-- Jump to nvim/ulazy/fzf-lua.lua#id=theme-autocmd
```

### 2. Pattern-based navigation

```lua
-- See nvim/uinit.lua#statusline
-- Jump to nvim/ulazy/conform.lua#formatters_by_ft
```

### 3. Traditional line numbers (still supported)

```lua
-- See nvim/uinit.lua:107
```

### 4. Plain file paths

```lua
-- See nvim/uinit.lua
```

## Usage

1. Place cursor on a line containing a navigation pattern
2. Press `gf` to navigate
3. Use `<C-w>f` for split, `<C-w>gf` for tab

## ID Tag Search

Press `<Leader>oi` to search all `id=` tags across your config with fzf-lua.

## Configuration

The plugin is configured in `nvim/ulazy/unavigate.lua` with these defaults:

```lua
{
  keymaps = true,              -- Enable default keymaps
  id_search_keymap = '<Leader>oi',  -- Keymap for ID search
}
```

## Examples from Your Config

Your config already uses the `id=` pattern extensively:

```lua
-- id=keymaps
-- id=lazy.nvim-setup2
-- id=util-set_theme_with_fallback
```

Now you can reference these from anywhere:

```lua
-- See nvim/uinit.lua#id=keymaps
```

Place cursor on that line and press `gf` - it will jump directly to the keymaps section!
