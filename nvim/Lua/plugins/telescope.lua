return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", name = "fzf" },
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		telescope.setup({
			extensions = {
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case",
				},
			},
			pickers = {
				oldfiles = {
					cwd_only = true,
				},
				find_files = {
					hidden = true,
				},
			},
		})
		telescope.load_extension("fzf")

		local function grep_with_selection()
			vim.cmd('noau normal! "vy"')
			local search_text = vim.fn.getreg("v")
			builtin.live_grep({
				default_text = search_text,
			})
		end

		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
		vim.keymap.set("n", "<leader>fe", function()
			builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
		end, { desc = "Telescope Explorer" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
		vim.keymap.set("v", "<leader>fg", grep_with_selection, { desc = "Telescope live grep" })
		vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { desc = "Telescope references" })
		vim.keymap.set("n", "<leader>fr", function()
			builtin.oldfiles({ cwd = vim.fn.expand("%:p:h") })
		end, { desc = "Telescope recent files" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

		vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
		vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
	end,
}
