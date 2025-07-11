local u = require("u.utils")
local IIF = u.IIF

local uname = vim.uv.os_uname()
local g = vim.g
local o = vim.o

-- Disable Python 3 support for faster startup
g.loaded_python3_provider = 0

-- :h g:vimsyn_embed
g.vimsyn_embed = "lP"

-- navigation
o.mouse = IIF(uname.machine == "x86_64", "a", "")

-- backup copy
-- to prevent watch-enabled Bun instance from crashing
o.backupcopy = "yes"

-- :h 'modeline'
o.modeline = false

-- :h 'showmode'
o.showmode = false

-- id=clipboard
o.clipboard = "unnamedplus"

-- BUG?: `<Space>` cannot be used.
g.mapleader = " "

-- tab
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- content
o.ffs = "unix,dos"
o.fixeol = false -- o.fixendofline

-- search
o.ignorecase = true

-- styling
o.number = true
o.relativenumber = true
o.termguicolors = true
o.laststatus = 3

-- id=disable-macro
local alphanumeric = {}
for i = 1, 26 do
	table.insert(alphanumeric, string.char(64 + i))
	table.insert(alphanumeric, string.char(96 + i))
end
for i = 0, 9 do
	table.insert(alphanumeric, tostring(i))
end
for _, char in ipairs(alphanumeric) do
	vim.keymap.set({ "n", "v" }, "q" .. char, "", { desc = "noop" })
end

-- id=keymaps
vim.keymap.set({ "n", "v" }, ";", ":", { desc = "No-Shift Ex mode" })
vim.keymap.set("n", "qw", ":w<CR>", { desc = "Quick/easy save", silent = true })
vim.keymap.set("n", "qq", ":q<CR>", { desc = "Quick/easy quit", silent = true })
vim.keymap.set("n", "qa", ":qa<CR>", { desc = "Quick/easy quit all", silent = true })
vim.keymap.set("n", "qfa", ":qa!<CR>", { desc = "Quick/easy quit all (force)", silent = true })
vim.keymap.set("n", "qe", ":e<CR>", { desc = "Quick/easy reload", silent = true })
vim.keymap.set("n", "qs", ":mksession! ", { desc = "Quick/easy save session" })
vim.keymap.set("n", "<Leader>xll", ":.lua<CR>", { desc = "Execute Lua on current line", silent = true })
vim.keymap.set("v", "<Leader>xll", ":'<,'>lua<CR>", { desc = "Execute Lua on selection", silent = true })
