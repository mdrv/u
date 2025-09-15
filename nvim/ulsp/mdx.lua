-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/mdx_analyzer.lua

-- https://github.com/neovim/nvim-lspconfig/blob/c671605/lua/lspconfig/util.lua#L89
function get_typescript_server_path(root_dir)
	local project_roots = vim.fs.find("node_modules", { path = root_dir, upward = true, limit = math.huge })
	for _, project_root in ipairs(project_roots) do
		local typescript_path = project_root .. "/typescript"
		local stat = vim.loop.fs_stat(typescript_path)
		if stat and stat.type == "directory" then
			return typescript_path .. "/lib"
		end
	end
	return ""
end

return {
	cmd = { "mdx-language-server", "--stdio" },
	filetypes = { "mdx" },
	root_markers = { "tsconfig.json", "package.json" },
	settings = {},
	init_options = {
		typescript = {}
	},
	before_init = function(_, config)
		if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
			config.init_options.typescript.tsdk = get_typescript_server_path(config.root_dir)
		end
	end,
}
