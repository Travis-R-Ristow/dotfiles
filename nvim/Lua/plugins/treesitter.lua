return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {},
	config = function()
		local treesitter = require("nvim-treesitter.configs")
		treesitter.setup({
			indent = { enable = true },
			autotag = { enable = true },
			sync_install = false,
			ensure_installed = {
				"javascript",
				"typescript",
				"html",
				"css",
				"tsx",
				"lua",
				"graphql",
				"markdown",
			},
			auto_install = true,
			ignore_install = {},
			modules = {},
			highlight = {
				enable = true,
			},
		})

		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt.foldminlines = 100
		vim.opt.foldnestmax = 0
	end,
}
