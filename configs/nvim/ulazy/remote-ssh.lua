-- https://github.com/inhesrom/remote-ssh.nvim

--- @type LazySpecPlugin
return {
    "inhesrom/remote-ssh.nvim",
    branch = "master",
    dependencies = {
        "inhesrom/telescope-remote-buffer", --See https://github.com/inhesrom/telescope-remote-buffer for features
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
        -- nvim-notify is recommended, but not necessarily required into order to get notifcations during operations - https://github.com/rcarriga/nvim-notify
        "rcarriga/nvim-notify",
    },
    config = function ()
        require('telescope-remote-buffer').setup(
            -- Default keymaps to open telescope and search open buffers including "remote" open buffers
            --fzf = "<leader>fz",
            --match = "<leader>gb",
            --oldfiles = "<leader>rb"
        )

        require('remote-ssh').setup({
            on_attach = vim.lsp.config.on_attach,
            capabilities = vim.lsp.config.capabilities,
            filetype_to_server = vim.lsp.config.filetype_to_server
        })
    end
}
