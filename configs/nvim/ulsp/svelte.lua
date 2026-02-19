-- id=lsp-svelte
-- l: https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/configs/svelte.lua
--- @type vim.lsp.Config
return {
	cmd = { 'svelteserver', '--stdio' },
	-- i: To enable file watcher
	-- l: https://github.com/sveltejs/language-tools/issues/2008#issuecomment-2898485264
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
			pattern = { '*.js', '*.ts' },
			callback = function(ctx)
				client:notify('$/onDidChangeTsOrJsFile', {
					uri = ctx.match,
				})
			end,
		})
	end,
	filetypes = { 'svelte' },
	root_markers = { 'package.json' },
	settings = {
		svelte = {
			plugin = {
				css = {
					diagnostics = {
						enable = true,
					},
				},
				svelte = {
					-- seems won’t function; use package.json `prettier` property instead.
					format = {
						config = {
							singleQuote = true,
							semi = false,
						},
					},
				},
			},
		},
		-- https://github.com/sveltejs/language-tools/blob/master/docs/preprocessors/other-css-preprocessors.md#tailwindcss
		css = {
			lint = {
				unknownAtRules = 'ignore',
			},
		},
		scss = {
			lint = {
				unknownAtRules = 'ignore',
			},
		},
		typescript = {
			updateImportsOnFileMove = {
				enabled = 'always', -- does not seem to be working
			},
		},
	},
}
