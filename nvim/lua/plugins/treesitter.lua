return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		vim.opt.foldmethod = "manual"
		vim.opt.foldtext = ""
	end,
}
