return {
	"mikavilpas/yazi.nvim",
	-- event = "VeryLazy",
	keys = {
		{
			"<leader>y",
			"<cmd>Yazi<cr>",
			desc = "Opens vim-Yazi",
		},
	},
	opts = {
		open_for_directories = true,
	},
	config = function(_, opts)
		require("yazi").setup(opts)
	end,
}
