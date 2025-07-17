-- @link https://cmp.saghen.dev/configuration/completion.html#treesitter
return {
	"saghen/blink.cmp",
	enabled = true,
	dependencies = {
		"xzbdmw/colorful-menu.nvim",
		-- "rafamadriz/friendly-snippets",
		-- "Kaiser-Yang/blink-cmp-dictionary",
		"moyiz/blink-emoji.nvim",
		-- "fang2hou/blink-copilot",
		-- "milanglacier/minuet-ai.nvim",
	},
	version = "1.*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		fuzzy = {
			sorts = {
				-- must specify all used sorts
				"exact",
				"score",
				"sort_text",
			},
		},
		completion = {
			-- recommended for minuet-ai.nvim
			-- trigger = { prefetch_on_insert = false },
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				},
			},
			documentation = { window = { border = "bold" } },
			menu = {
				border = "rounded",
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", gap = 1 },
						{ "source_name" },
					},
					components = {
						source_name = {
							width = { max = 30 },
							text = function(ctx)
								return ctx.source_name
							end,
							highlight = "BlinkCmpGhostText",
						},
						label = {
							text = function(ctx)
								return require("colorful-menu").blink_components_text(ctx)
							end,
							highlight = function(ctx)
								return require("colorful-menu").blink_components_highlight(ctx)
							end,
						},
					},
				},
			},
		},
		sources = {
			default = { "lsp", "path", "emoji" },
			providers = {
				emoji = {
					module = "blink-emoji",
					name = "Emoji",
					score_offset = 10,
				},
			},
		},
	},
}
