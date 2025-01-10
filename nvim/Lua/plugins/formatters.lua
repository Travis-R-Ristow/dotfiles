return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewfile" },
		config = function()
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					css = { "prettier" },
					html = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					graphql = { "prettier" },
					lua = { "stylua" },
				},
				format_on_save = {
					lsp_fallback = true,
					async = false,
					timeout_ms = 5000,
				},
			})
		end,
	},
	-- {
	-- 	"nvimtools/none-ls.nvim",
	-- 	"davidmh/cspell.nvim",
	-- 	event = { "BufReadPre", "BufNewFile" },
	-- 	config = function()
	-- 		local noneLsp = require("none-ls")
	-- 		local cspell = require("cspell")
	--
	-- 		noneLsp.setup({
	-- 			sources = {
	-- 				cspell.diagnostics,
	-- 				-- cspell.code_actions,
	-- 			},
	-- 		})
	-- 	end,
	-- },
}
