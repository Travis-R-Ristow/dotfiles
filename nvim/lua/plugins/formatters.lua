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
				format_on_save = function(bufnr)
					if not vim.g.format_changed_only then
						return {
							lsp_fallback = true,
							async = false,
							timeout_ms = 5000,
						}
					end

					local gitsigns = package.loaded.gitsigns
					if not gitsigns then
						return
					end

					local hunks = gitsigns.get_hunks(bufnr)
					if not hunks or #hunks == 0 then
						return
					end

					for i = #hunks, 1, -1 do
						local hunk = hunks[i]
						if hunk.added.count > 0 then
							local start_line = hunk.added.start
							local end_line = start_line + hunk.added.count - 1
							local end_col = #vim.fn.getline(end_line)
							conform.format({
								bufnr = bufnr,
								lsp_fallback = true,
								async = false,
								timeout_ms = 5000,
								range = {
									start = { start_line, 0 },
									["end"] = { end_line, end_col },
								},
							})
						end
					end
				end,
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
