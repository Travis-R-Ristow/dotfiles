return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewfile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          javascript = { "biome" },
          typescript = { "biome" },
          javascriptreact = { "biome" },
          typescriptreact = { "biome" },
          css = { "biome" },
          html = { "biome" },
          json = { "biome" },
          yaml = { "biome" },
          graphql = { "biome" },
          markdown = { "prettier" },
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
