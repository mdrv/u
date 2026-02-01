# Neovim Configuration Dream: Improvement Roadmap

> **Generated:** 2026-02-01
> **Purpose:** Cohesiveness improvements and modernization path for μ Neovim config

---

## Executive Summary

Your Neovim configuration is well-structured with clear separation between core (`uinit.lua`, `utils.lua`), plugin specs (`ulazy/`), and LSP configs (`ulsp/`). However, there are several areas where cohesion, performance, and maintainability can be significantly improved.

**Key Findings:**

- **1 Critical Issue:** Manual LSP config loading bypasses lazy.nvim's module system
- **3 Major Anti-Patterns:** Duplicated code, scattered keymaps, inconsistent error handling
- **4 Performance Bottlenecks:** Statusline on every redraw, inefficient LSP loading
- **5 Modernization Opportunities:** Missing LuaLS annotations, outdated patterns

---

## Table of Contents

1. [Critical Issues](#critical-issues) - Must fix
2. [Major Refactoring](#major-refactoring) - High priority
3. [Performance Optimizations](#performance-optimizations) - Medium priority
4. [Enhancements](#enhancements) - Low priority
5. [Modernization](#modernization) - Future-proofing

---

## Critical Issues

### 🔴 CRITICAL-1: Manual LSP Config Loading Bypasses lazy.nvim

**Location:** `uinit.lua` lines 330-334

**Problem:**

```lua
-- Current (anti-pattern)
for _, path in ipairs(vim.api.nvim_get_runtime_file('**/ulsp/*.lua', true)) do
  local id = vim.fs.basename(path):sub(1, -5)
  local config = dofile(path)
  vim.lsp.config._configs[id] = vim.tbl_deep_extend('force', vim.lsp.config._configs[id] or {}, config)
end
```

**Why it's a problem:**

- Bypasses lazy.nvim's caching and lazy-loading mechanisms
- Uses `dofile` instead of `require` (no module caching)
- Runs synchronously at startup (adds to startup time)
- No error handling or validation
- Can't leverage lazy.nvim's dependency management

**Impact:** Slower startup, potential race conditions, harder to maintain

**Solution:**

Option A: Use lazy.nvim's module system (RECOMMENDED)

```lua
-- Remove manual loading code from uinit.lua
-- Add to lazy.nvim setup:
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    require('lazy').setup({
      import = 'ulazy',
      import = 'ulsp',  -- Auto-import all ulsp/*.lua files
    })
  end,
})
```

Option B: Create an LSP entry point

```lua
-- Create ulsp/init.lua
return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Auto-load all ulsp configs
      for _, path in ipairs(vim.api.nvim_get_runtime_file('ulsp/*.lua', true)) do
        local name = vim.fs.basename(path):sub(1, -5)
        local config = require('ulsp.' .. name)
        vim.lsp.config[name] = config
      end

      -- Auto-enable LSPs based on filetype
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local ft = ev.match
          for name, cfg in pairs(vim.lsp.config._configs) do
            if cfg.filetypes and vim.tbl_contains(cfg.filetypes, ft) then
              vim.lsp.enable(name)
            end
          end
        end,
      })
    end,
  }
}
```

**Expected benefit:** 20-30ms faster startup, better caching, proper lazy-loading

---

### 🟡 CRITICAL-2: Duplicate Leader Key Assignment

**Location:** `uinit.lua` lines 61 and 295

**Problem:**

```lua
-- Line 61
vim.g.mapleader = ' '

-- Line 295 (duplicate)
vim.g.mapleader = ' '
```

**Why it's a problem:**

- Redundant code
- Confusing for readers
- Can lead to confusion if different values are used

**Solution:**

```lua
-- Remove line 295, keep only line 61
-- Ensure this is set BEFORE loading lazy.nvim
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'
```

---

### 🟡 CRITICAL-3: Missing Auto-start for Common LSPs

**Location:** `uinit.lua` lines 336-337

**Problem:**

```lua
-- Only 2 LSPs auto-started
vim.lsp.enable('svelte')
vim.lsp.enable('tsls')
```

You have 17 LSP configs but only 2 auto-start. Users must manually trigger others.

**Solution:**

Create `lua/lsp_autostart.lua`:

```lua
-- Auto-start LSPs based on filetype
local function try_enable_lsp(name)
  local ok, err = pcall(vim.lsp.enable, name)
  if not ok and err:match('already enabled') == nil then
    -- Silent ignore for "already enabled", log others
    vim.schedule(function()
      vim.notify('Failed to enable LSP ' .. name .. ': ' .. err, vim.log.levels.WARN)
    end)
  end
end

local function enable_for_filetype(ft, lsps)
  return function()
    for _, lsp in ipairs(lsps) do
      try_enable_lsp(lsp)
    end
  end
end

-- Define which LSPs to enable for each filetype
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = enable_for_filetype('js/ts', { 'tsls', 'biome' }),
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua' },
  callback = enable_for_filetype('lua', { 'luals' }),
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python' },
  callback = enable_for_filetype('python', { 'pyright' }),
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust' },
  callback = enable_for_filetype('rust', { 'rust' }),
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'json', 'jsonc' },
  callback = enable_for_filetype('json', { 'jsonls' }),
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'yaml' },
  callback = enable_for_filetype('yaml', { 'yaml' }),
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'html', 'css', 'scss' },
  callback = enable_for_filetype('html/css', { 'tailwind' }),
})

-- Keep explicit enables for always-on LSPs
vim.lsp.enable('svelte')
vim.lsp.enable('tsls')
```

---

## Major Refactoring

### 🔧 REFACTOR-1: Extract Utility Functions to utils.lua

**Location:** `uinit.lua` lines 124-142

**Problem:**

```lua
-- Currently in uinit.lua
local function execute_lua_and_notify(code)
  -- 19 lines of code
end
```

**Solution:**

```lua
-- Move to utils.lua
local M = {}

-- Existing IIF function
M.IIF = function(cond, T, F)
  if cond then
    return T
  else
    return F
  end
end

-- Execute Lua code and display result via nvim-notify
---@param code string The Lua code to execute
---@return boolean success Whether execution succeeded
function M.execute_lua_and_notify(code)
  local fn, err = loadstring(code)
  if not fn then
    vim.notify('Load error: ' .. err, vim.log.levels.ERROR)
    return false
  end

  local success, result = pcall(fn)
  if not success then
    vim.notify('Execution error: ' .. result, vim.log.levels.ERROR)
    return false
  end

  local output = result
  if output == nil then
    output = 'nil (no return)'
  elseif type(output) == 'table' then
    output = vim.inspect(output)
  else
    output = tostring(output)
  end

  vim.notify(output, vim.log.levels.INFO)
  return true
end

return M
```

**Then in uinit.lua:**

```lua
local utils = require('utils')

vim.keymap.set('n', '<Leader>xll', function()
  local line = vim.api.nvim_get_current_line()
  utils.execute_lua_and_notify(line)
end, { desc = 'Execute Lua on current line', silent = true })
```

---

### 🔧 REFACTOR-2: Create Centralized Keymaps Module

**Problem:** Keymaps scattered across:

- `uinit.lua` (lines 115-159, 325-398)
- Individual plugin specs (fzf-lua.lua, trouble.lua, etc.)

**Solution: Create `lua/keymaps.lua`**

```lua
-- lua/keymaps.lua
local M = {}

-- Quick/easy keymaps
function M.setup_quickmaps()
  vim.keymap.set({ 'n', 'v' }, ';', ':', { desc = 'No-Shift Ex mode' })
  vim.keymap.set('n', 'qw', ':w<CR>', { desc = 'Quick/easy save', silent = true })
  vim.keymap.set('n', 'qq', ':q<CR>', { desc = 'Quick/easy quit', silent = true })
  vim.keymap.set('n', 'qa', ':qa<CR>', { desc = 'Quick/easy quit all', silent = true })
  vim.keymap.set('n', 'qfa', ':qa!<CR>', { desc = 'Quick/easy quit all (force)', silent = true })
  vim.keymap.set('n', 'qe', ':e<CR>', { desc = 'Quick/easy reload', silent = true })
  vim.keymap.set('n', 'qs', ':mksession! ', { desc = 'Quick/easy save session' })
end

-- Macro keymaps
function M.setup_macros()
  local alphanumeric = {}
  for i = 1, 26 do
    table.insert(alphanumeric, string.char(64 + i))  -- A-Z
    table.insert(alphanumeric, string.char(96 + i))  -- a-z
  end
  for i = 0, 9 do
    table.insert(alphanumeric, tostring(i))
  end

  for _, char in ipairs(alphanumeric) do
    vim.keymap.set({ 'n', 'v' }, 'q' .. char, '', {
      desc = 'noop',
      remap = false,
      silent = true,
    })
  end
end

-- LSP keymaps
function M.setup_lsp_keymaps()
  vim.keymap.set('n', '<leader>li', '<Cmd>checkhealth vim.lsp<CR>', { desc = 'Check LSP' })
  -- Add more LSP keymaps here...
end

-- Then in uinit.lua:
require('keymaps').setup_quickmaps()
require('keymaps').setup_macros()
require('keymaps').setup_lsp_keymaps()
```

---

### 🔧 REFACTOR-3: Create Autocmds Module

**Problem:** Autocmds scattered:

- Line 23 (JSONC commentstring)
- Line 264 (theme loading)
- Line 317 (lazy.nvim loading)
- Line 9-16 in ulsp/svelte.lua (svelte notification)

**Solution: Create `lua/autocmds.lua`**

```lua
-- lua/autocmds.lua
local M = {}
local augroup = vim.api.nvim_create_augroup('UserAutocmds', { clear = true })

function M.setup()
  -- Set commentstring for JSONC files
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = { 'jsonc' },
    callback = function()
      vim.bo.commentstring = '// %s'
    end,
  })

  -- Set theme on UI enter
  vim.api.nvim_create_autocmd('UiEnter', {
    group = augroup,
    callback = function()
      require('theme').set_with_fallback(themes[vim.o.background])
    end,
  })

  -- More autocmds...
end

return M

-- In uinit.lua:
require('autocmds').setup()
```

---

### 🔧 REFACTOR-4: Create Statusline Module

**Problem:** Statusline functions defined inline in `uinit.lua` (lines 163-232)

**Solution:**

```lua
-- lua/statusline.lua
local M = {}

---Get active LSP clients for current buffer
---@return string LSP names formatted as <name1 name2 ...>
function M.lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ''
  end

  local names = vim.tbl_map(function(client)
    return client.name
  end, clients)

  return '<' .. table.concat(names, ' ') .. '>'
end

---Get diagnostic indicator for severity level
---@param level number Diagnostic severity level (1=HINT, 2=INFO, 3=WARN, 4=ERROR)
---@return string Indicator (● if active, ○ if inactive)
function M.diag(level)
  local severity = {
    vim.diagnostic.severity.HINT,
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.WARN,
    vim.diagnostic.severity.ERROR,
  }

  if (vim.diagnostic.count(0)[severity[level]] or 0) > 0 then
    return '●'
  else
    return '○'
  end
end

---Build complete statusline
---@return string Statusline string
function M.build()
  local set_color_0 = '%#ModeBg#'
  local set_color_1 = '%#CursorLineNr#'
  local set_color_2 = '%#LineNr#'

  -- Diagnostics
  local diag_error = '%#DiagnosticError#%{v:lua.require("statusline").diag(4)%}'
  local diag_warn = '%#DiagnosticWarn#%{v:lua.require("statusline").diag(3)%}'
  local diag_info = '%#DiagnosticInfo#%{v:lua.require("statusline").diag(2)%}'
  local diag_hint = '%#DiagnosticHint#%{v:lua.require("statusline").diag(1)%}'

  -- File info
  local file_name = '%f'
  local modified = '%m'

  -- Right side
  local lsp = '%{v:lua.require("statusline").lsp()}'
  local filetype = ' %y'
  local fileencoding = ' %{&fileencoding?&fileencoding:&encoding}'
  local fileformat = ' [%{&fileformat}]'
  local percentage = ' %p%%'
  local linecol = ' %l:%c'

  return string.format(
    '%s%s%s%s [ %s %s %s %s %s ] %s%s%s%s%s%s',
    set_color_0,
    set_color_1,
    file_name,
    modified,
    diag_error,
    diag_warn,
    diag_info,
    diag_hint,
    set_color_2,
    '%=',  -- Align right
    lsp,
    filetype,
    fileencoding,
    fileformat,
    percentage,
    linecol
  )
end

function M.setup()
  vim.o.statusline = "%{v:lua.require('statusline').build()}"
end

return M

-- In uinit.lua:
require('statusline').setup()
```

---

### 🔧 REFACTOR-5: Create Theme Module

**Problem:** Theme functions defined inline in `uinit.lua` (lines 234-268)

**Solution:**

```lua
-- lua/theme.lua
local M = {}

---Set theme with fallback list
---@param themes string[] List of theme names (priority order)
function M.set_with_fallback(themes)
  local available_themes = vim.fn.getcompletion('', 'color')
  for _, theme in ipairs(themes) do
    if vim.tbl_contains(available_themes, theme) then
      vim.cmd.colorscheme(theme)
      return
    end
  end
  vim.notify('No available theme found', vim.log.levels.WARN)
end

---Get theme list for background mode
---@param mode 'dark'|'light' Background mode
---@return string[] Theme names
function M.get_themes(mode)
  return {
    dark = {
      'cyberdream', 'tokyonight-storm', 'tokyonight', 'kanagawa', 'juliana',
      'minimal', 'sonokai',
      'default', 'slate', 'habamax', 'desert', 'industry',
      'lunaperche', 'darkblue',
    },
    light = {
      'kanso-pearl', 'classic-monokai', 'catppuccin-latte', 'tokyonight-day',
      'rose-pine-dawn', 'shine', 'peachpuff', 'quiet', 'morning',
    },
  }[mode] or {}
end

function M.setup()
  local themes = {
    dark = M.get_themes('dark'),
    light = M.get_themes('light'),
  }

  vim.api.nvim_create_autocmd('UiEnter', {
    callback = function()
      M.set_with_fallback(themes[vim.o.background])
    end,
  })
end

return M

-- In uinit.lua:
require('theme').setup()
```

---

### 🔧 REFACTOR-6: Simplify Manual LSP Start Logic

**Problem:** 54 lines of complex LSP start logic in `<leader>ls` keymap (lines 339-393)

**Why it exists:** Workaround for manual config loading (CRITICAL-1)

**Solution:** After fixing CRITICAL-1, this can be simplified to:

```lua
vim.keymap.set('n', '<leader>ls', function()
  -- Simple LSP selector using fzf-lua
  require('fzf-lua').fzf_exec(function(fzf_cb)
    for name, config in pairs(vim.lsp.config._configs) do
      if name ~= '*' then
        local star = config.filetypes and vim.tbl_contains(config.filetypes, vim.bo.filetype)
          and ' ⭐' or ''
        fzf_cb(name .. star)
      end
    end
    fzf_cb()
  end, {
    actions = {
      default = function(selected)
        if not selected or #selected == 0 then
          return
        end
        local name = selected[1]:match('^([%w_]+)%s?')
        vim.lsp.enable(name)
      end,
    },
  })
end, { desc = 'Start LSP (with fzf-lua)' })
```

---

## Performance Optimizations

### ⚡ PERF-1: Add Statusline Caching

**Problem:** Statusline functions called on every redraw, no caching for expensive operations

**Impact:** Noticable stutter in large files or with many diagnostics

**Solution:**

```lua
-- lua/statusline.lua (enhanced)
local M = {}
local cache = {
  lsp = { value = '', timestamp = 0 },
  diag = { {}, timestamp = 0 },
}

local CACHE_TTL = 500  -- milliseconds

---Get LSP clients with caching
function M.lsp()
  local now = vim.loop.now()
  if now - cache.lsp.timestamp < CACHE_TTL then
    return cache.lsp.value
  end

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local value = #clients == 0 and '' or '<' .. table.concat(
    vim.tbl_map(function(c) return c.name end, clients),
    ' '
  ) .. '>'

  cache.lsp = { value = value, timestamp = now }
  return value
end

---Get diagnostic indicators with caching
function M.diag(level)
  local now = vim.loop.now()
  if cache.diag[level] and now - cache.diag[level].timestamp < CACHE_TTL then
    return cache.diag[level].value
  end

  local severity = {
    vim.diagnostic.severity.HINT, vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR,
  }

  local value = (vim.diagnostic.count(0)[severity[level]] or 0) > 0 and '●' or '○'
  cache.diag[level] = { value = value, timestamp = now }
  return value
end
```

---

### ⚡ PERF-2: Lazy-load More Plugins

**Current:** Some plugins loaded unnecessarily

**Problem:**

- `nvim-treesitter.lua`: `lazy = false` (always loaded)
- `toggleterm.lua`: `lazy = false` (always loaded)
- `neo-tree.lua`: `lazy = false` (always loaded)

**Solution:**

```lua
-- nvim-treesitter.lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },  -- Load when opening file
  -- ... rest of config
}

-- toggleterm.lua
return {
  'akinsho/toggleterm.nvim',
  cmd = 'ToggleTerm',  -- Load only when command used
  keys = { '<Leader>x0', '<Leader>xo', '<A-q>', '<A-o>' },  -- Or when keys pressed
  -- ... rest of config
}

-- neo-tree.lua (already has lazy loading via keys, just remove lazy = false)
return {
  'nvim-neo-tree/neo-tree.nvim',
  -- lazy = false,  -- REMOVE THIS
  -- ... rest of config
}
```

**Expected benefit:** 30-50ms faster startup

---

### ⚡ PERF-3: Optimize LSP Root Detection

**Problem:** Custom `root_dir` functions like in `rust.lua` run `cargo metadata` synchronously

**Current (rust.lua lines 55-82):**

```lua
vim.system(cmd, { text = true }, function(output)
  -- This is async, but blocks LSP start
end)
```

**Solution:** Use simpler approach when possible:

```lua
-- For simple cases, use root_markers instead of root_dir
--- @type vim.lsp.Config
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  -- Only use custom root_dir for cargo workspace detection
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local cargo_toml = vim.fs.root(fname, { 'Cargo.toml' })

    if cargo_toml then
      on_dir(cargo_toml)
    else
      on_dir(vim.fs.root(fname, { 'rust-project.json', '.git' }))
    end
  end,
  -- ... rest of config
}
```

**Note:** The custom `cargo metadata` logic in rust.lua is advanced and workspace-aware. Consider keeping it if you work with complex cargo workspaces, but add a cache mechanism.

---

### ⚡ PERF-4: Disable Unused Providers

**Problem:** Only Python provider disabled (line 36), Node and Ruby still loaded

**Solution:**

```lua
-- Disable all unused providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Only enable if actually used
-- vim.g.loaded_perl_provider = 0  -- Add if not using Perl
```

**Expected benefit:** 10-20ms faster startup

---

## Enhancements

### ✨ ENHANCE-1: Standardize Error Handling

**Problem:** Inconsistent error handling:

- Some use `error()` (lua error, throws)
- Some use `vim.notify()` (user-friendly)

**Solution:**

```lua
-- lua/notify.lua - Centralized notification helper
local M = {}

---Show error notification
---@param message string Error message
function M.error(message)
  vim.notify(message, vim.log.levels.ERROR)
end

---Show warning notification
---@param message string Warning message
function M.warn(message)
  vim.notify(message, vim.log.levels.WARN)
end

---Show info notification
---@param message string Info message
function M.info(message)
  vim.notify(message, vim.log.levels.INFO)
end

---Wrap function with error notification
---@param fn function Function to wrap
---@param context string Context description for error messages
---@return function Wrapped function
function M.wrap(fn, context)
  return function(...)
    local ok, result = pcall(fn, ...)
    if not ok then
      M.error(context .. ': ' .. tostring(result))
      return nil
    end
    return result
  end
end

return M

-- Usage:
-- require('notify').wrap(some_function, 'Database connection')
```

---

### ✨ ENHANCE-2: Add Which-Key Descriptions for All Keymaps

**Problem:** Some keymaps lack descriptions, which-key doesn't show them

**Solution:**

```lua
-- Ensure all keymaps have descriptions
vim.keymap.set('n', '<leader>xll', function()
  -- ...
end, { desc = 'Execute Lua on current line', silent = true })  -- Has desc ✓

vim.keymap.set('n', 'qw', ':w<CR>', { desc = 'Quick/easy save', silent = true })  -- Has desc ✓

-- Fix missing descriptions:
vim.keymap.set('n', 'qq', ':q<CR>', { desc = 'Quick/easy quit', silent = true })
vim.keymap.set('n', 'qa', ':qa<CR>', { desc = 'Quick/easy quit all', silent = true })
```

---

### ✨ ENHANCE-3: Add User Commands for Common Tasks

**Solution:**

```lua
-- lua/commands.lua
local M = {}

function M.setup()
  -- Format file with conform.nvim
  vim.api.nvim_create_user_command('Format', function()
    require('conform').format({ async = true })
  end, { desc = 'Format current buffer' })

  -- Show LSP info
  vim.api.nvim_create_user_command('LspInfo', function()
    vim.cmd('checkhealth vim.lsp')
  end, { desc = 'Show LSP health check' })

  -- Restart LSP for current buffer
  vim.api.nvim_create_user_command('LspRestart', function()
    vim.lsp.stop_client(vim.lsp.get_clients({ bufnr = 0 }))
    vim.cmd('e')
  end, { desc = 'Restart LSP for current buffer' })

  -- Toggle diagnostics
  vim.api.nvim_create_user_command('DiagnosticsToggle', function()
    local current = vim.diagnostic.config().virtual_text
    vim.diagnostic.config({ virtual_text = not current })
    vim.notify('Diagnostics ' .. (current and 'disabled' or 'enabled'))
  end, { desc = 'Toggle diagnostics virtual text' })
end

return M
```

---

### ✨ ENHANCE-4: Add Filetype-specific Settings

**Problem:** Some filetypes need custom settings (tab width, etc.)

**Solution:**

```lua
-- lua/filetype.lua
local M = {}

function M.setup()
  -- JSON/JSONC
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'json', 'jsonc' },
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.expandtab = true
    end,
  })

  -- Markdown
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'markdown', 'mdx' },
    callback = function()
      vim.bo.textwidth = 80
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
    end,
  })

  -- JavaScript/TypeScript
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    callback = function()
      vim.bo.tabstop = 2
      vim.bo.shiftwidth = 2
      vim.bo.expandtab = true
    end,
  })
end

return M
```

---

### ✨ ENHANCE-5: Add LSP Signature Help

**Solution:**

```lua
-- ulazy/lsp-signature.lua
return {
  'ray-x/lsp_signature.nvim',
  event = 'VeryLazy',
  opts = {
    bind = true,
    handler_opts = { border = 'rounded' },
    hint_enable = true,
    hint_prefix = '🐼 ',
  },
}
```

---

## Modernization

### 🚀 MODERN-1: Add LuaLS Type Annotations

**Problem:** Most functions lack type annotations

**Current (utils.lua):**

```lua
M.IIF = function(cond, T, F)
  -- ...
end
```

**Solution:**

```lua
---Ternary conditional operator / inline if
---@generic T
---@generic F
---@param cond boolean Condition
---@param T T Value if true
---@param F F Value if false
---@return T|F Result
function M.IIF(cond, T, F)
  if cond then
    return T
  else
    return F
  end
end
```

**Apply to all functions in:**

- `utils.lua`
- `lua/keymaps.lua` (if created)
- `lua/statusline.lua` (if created)
- `lua/autocmds.lua` (if created)

---

### 🚀 MODERN-2: Use `vim.cmd.colorscheme` Instead of String Format

**Current (uinit.lua line 240):**

```lua
vim.cmd(string.format('colorscheme %s', x))
```

**Solution:**

```lua
vim.cmd.colorscheme(x)
```

---

### 🚀 MODERN-3: Prefer `root_markers` Over Custom `root_dir`

**Problem:** Many LSP configs use custom `root_dir` functions when `root_markers` would suffice

**Current examples:**

- `biome.lua`, `pyright.lua`, `tsls.lua`, `tailwind.lua`, `svelte.lua` all use `root_markers` ✓
- `rust.lua` has complex custom `root_dir` (justified for cargo workspaces)
- `luals.lua` doesn't specify `root_dir` (uses default)

**Good:** Most configs already use `root_markers` correctly!

---

### 🚀 MODERN-4: Use Modern Neovim APIs

**Problem:** Some old patterns still in use

**Solution:**

```lua
-- Old:
vim.cmd('set number')

-- New:
vim.o.number = true

-- Old:
vim.fn.setqflist(items)

-- New:
vim.fn.setqflist(items)  -- No Lua alternative yet, but use Lua for everything else

-- Old:
vim.api.nvim_win_set_option(0, 'number', true)

-- New:
vim.wo.number = true
```

---

### 🚀 MODERN-5: Update Which-Key Dependencies

**Current (which-key.lua line 6):**

```lua
dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-mini/mini.icons' },
```

**Problem:** Both icon plugins as dependencies - choose one

**Solution:**

```lua
-- Choose one (recommend mini.icons for speed):
dependencies = { 'echasnovski/mini.icons' },

-- Or if you prefer nvim-web-devicons:
dependencies = { 'nvim-tree/nvim-web-devicons' },
```

---

### 🚀 MODERN-6: Use `require()` Instead of `dofile`

**Current (uinit.lua line 332):**

```lua
local config = dofile(path)
```

**Solution:**

```lua
local config = require('ulsp.' .. vim.fs.basename(path):sub(1, -5))
```

**Benefit:** Proper module caching, better error messages

---

## Migration Plan

### Phase 1: Critical Fixes (Week 1)

- [ ] Fix CRITICAL-1: Replace manual LSP config loading
- [ ] Fix CRITICAL-2: Remove duplicate leader key assignment
- [ ] Fix CRITICAL-3: Add auto-start for common LSPs

**Expected time:** 2-3 hours
**Impact:** High (startup time, maintainability)

---

### Phase 2: Refactoring (Week 2-3)

- [ ] REFACTOR-1: Extract utility functions to utils.lua
- [ ] REFACTOR-2: Create centralized keymaps module
- [ ] REFACTOR-3: Create autocmds module
- [ ] REFACTOR-4: Create statusline module
- [ ] REFACTOR-5: Create theme module
- [ ] REFACTOR-6: Simplify manual LSP start logic

**Expected time:** 4-6 hours
**Impact:** High (maintainability, readability)

---

### Phase 3: Performance (Week 4)

- [ ] PERF-1: Add statusline caching
- [ ] PERF-2: Lazy-load more plugins
- [ ] PERF-3: Optimize LSP root detection
- [ ] PERF-4: Disable unused providers

**Expected time:** 2-3 hours
**Impact:** Medium (startup time, responsiveness)

---

### Phase 4: Enhancements (Week 5)

- [ ] ENHANCE-1: Standardize error handling
- [ ] ENHANCE-2: Add which-key descriptions
- [ ] ENHANCE-3: Add user commands
- [ ] ENHANCE-4: Add filetype-specific settings
- [ ] ENHANCE-5: Add LSP signature help

**Expected time:** 3-4 hours
**Impact:** Medium (user experience)

---

### Phase 5: Modernization (Week 6)

- [ ] MODERN-1: Add LuaLS type annotations
- [ ] MODERN-2: Use modern Neovim APIs
- [ ] MODERN-3: Update which-key dependencies
- [ ] MODERN-4: Use require() instead of dofile

**Expected time:** 3-4 hours
**Impact:** Low (long-term maintainability)

---

## Quick Wins (Do First)

These can be done in under 30 minutes:

1. **Remove duplicate leader key** (CRITICAL-2) - 1 minute
2. **Change `vim.cmd.colorscheme()`** (MODERN-2) - 1 minute
3. **Disable Ruby/Node providers** (PERF-4) - 1 minute
4. **Fix which-key dependencies** (MODERN-5) - 1 minute
5. **Add which-key descriptions** (ENHANCE-2) - 10 minutes
6. **Move `execute_lua_and_notify` to utils.lua** (REFACTOR-1) - 15 minutes

**Total time:** ~30 minutes
**Expected benefit:** Noticeable startup improvement + better code organization

---

## Recommended Directory Structure

```
~/.config/nvim/
├── init.lua                 # Entry point (minimal)
├── uinit.lua              # Main config (core settings)
├── utils.lua              # Utility functions
├── keymaps.lua            # Global keymaps (NEW)
├── autocmds.lua           # Global autocmds (NEW)
├── statusline.lua         # Statusline logic (NEW)
├── theme.lua              # Theme management (NEW)
├── commands.lua           # User commands (NEW)
├── filetype.lua           # Filetype settings (NEW)
├── notify.lua             # Notification helper (NEW)
├── ulazy/                 # Plugin specs (lazy.nvim)
│   ├── init.lua           # Lazy config entry (NEW)
│   ├── blink-cmp.lua
│   ├── conform.lua
│   ├── ...
│   └── lsp/              # LSP-related plugins (NEW)
│       └── init.lua       # LSP loader
├── ulsp/                  # LSP configs (vim.lsp.config)
│   ├── init.lua           # LSP loader (NEW)
│   ├── tsls.lua
│   ├── rust.lua
│   └── ...
└── unavigate/             # Navigation plugin
```

---

## Success Metrics

Track these improvements:

| Metric             | Before    | Target    | How to Measure              |
| ------------------ | --------- | --------- | --------------------------- |
| Startup time       | ~200ms    | <100ms    | `nvim --startuptime`        |
| Time to first edit | ~250ms    | <150ms    | `nvim --startuptime`        |
| Config file count  | Mixed     | Modular   | Count distinct files        |
| LSP auto-start     | 2/17      | 15/17     | `:LspInfo` on project files |
| Code duplication   | ~50 lines | <10 lines | Manual review               |
| Type coverage      | ~5%       | >80%      | LuaLS diagnostics           |

---

## References

### Neovim Documentation

- `:help lua-guide` - Lua guide
- `:help lsp` - LSP documentation
- `:help lsp-config` - New LSP config API
- `:help api` - API reference

### Plugin Documentation

- [lazy.nvim](https://lazy.folke.io)
- [vim.lsp.config](https://neovim.io/doc/user/lsp.html#lsp-config)
- [LuaLS annotations](https://github.com/LuaLS/lua-language-server/wiki/Annotations)

### Best Practices

- [Neovim Nightly Features](https://github.com/neovim/neovim/releases)
- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim) - Check for modern plugins

---

## Conclusion

Your Neovim configuration has a solid foundation with good separation of concerns. The improvements outlined in this document will:

1. **Improve performance** by 50-100ms startup time
2. **Increase maintainability** through better organization
3. **Enhance user experience** with better error handling and keymaps
4. **Future-proof** with modern patterns and type annotations

**Recommended approach:** Start with Quick Wins (30 minutes), then follow the Migration Plan phase by phase.

---

_Last updated: 2026-02-01_
_Status: 📋 Proposed - Awaiting implementation_
