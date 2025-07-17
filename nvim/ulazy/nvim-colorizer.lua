return {
	"catgoose/nvim-colorizer.lua",
	enabled = true,
	event = "BufReadPre",
	opts = {
		filetypes = {
			"toml",
			"*",
		},
		user_default_options = {
			tailwind = false,
		},
	},
	cmd = "ColorizerToggle",
}
