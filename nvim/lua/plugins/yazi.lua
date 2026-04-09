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
		set_keymappings_function = function(yazi_buffer_id)
			vim.keymap.set("t", "<Esc>", function()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("q", true, false, true), "t", false)
			end, { buffer = yazi_buffer_id })
		end,
	},
	config = function(_, opts)
		require("yazi").setup(opts)
	end,
}
