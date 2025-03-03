return {
	"nvimdev/lspsaga.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("lspsaga").setup({
			ui = {
				code_action = "",
			},
		})

		vim.keymap.set("n", "<C-k>", "<Cmd>Lspsaga hover_doc<CR>")
		vim.keymap.set("n", "<C-S-k>", "<Cmd>Lspsaga peek_definition<CR>")
	end,
}
