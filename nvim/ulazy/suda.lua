return {
	"lambdalisue/suda.vim",
	enabled = true,
	lazy = false,
	init = function()
		vim.g.suda_smart_edit = 1
	end,
	cmd = { "SudaWrite", "SudaRead" },
}
