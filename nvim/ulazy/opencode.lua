-- https://github.com/NickvanDyke/opencode.nvim

--- @type LazyPluginSpec
return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			-- Fix for SSE decode errors and buffer glitching with neo-tree
			events = {
				enabled = true,        -- Keep SSE enabled
				reload = false,        -- Disable auto-reload to prevent buffer glitching
			},
			provider = {
				snacks = {
					auto_close = true,   -- Close terminal on exit
					win = {
						position = "right",
						enter = false,
					}
				}
			}
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true
		
		-- Suppress SSE decode error messages that cause screen flooding
		vim.opt.shortmess:append("S")

		-- Recommended/example keymaps.
		vim.keymap.set({ "n", "x" }, "<leader>za", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode" })
		vim.keymap.set({ "n", "x" }, "<leader>zx", function()
			require("opencode").select()
		end, { desc = "Execute opencode action…" })
		vim.keymap.set({ "n", "x" }, "<leader>zg", function()
			require("opencode").prompt("@this")
		end, { desc = "Add to opencode" })
		vim.keymap.set({ "n", "t" }, "<leader>zt", function()
			require("opencode").toggle()
		end, { desc = "Toggle opencode" })
		vim.keymap.set("n", "<leader>zu", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "opencode half page up" })
		vim.keymap.set("n", "<leader>zd", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "opencode half page down" })
		-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
		-- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
		-- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
	end,
}