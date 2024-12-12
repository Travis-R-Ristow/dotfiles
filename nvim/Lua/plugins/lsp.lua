return {
  {
    "williamboman/mason.nvim",
     dependencies = {
       "williamboman/mason-lspconfig.nvim",
     },
     config = function()
       local mason = require("mason")
       local lspconfig = require("mason-lspconfig")

       mason.setup()
       lspconfig.setup({
        indent = { enable = true },
        ensure_installed = {
          "ts_ls",
          "html",
          "cssls",
          "lua_ls",
          "graphql"
        }
       })
      end
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} }
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities();

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function()
          vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>")
        end
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities
          })
        end,
        ["ts_ls"] = function ()
          lspconfig.ts_ls.setup({
            capabilities = capabilities,
            root_dir = function (fname)
              return lspconfig.util.find_git_ancestor(fname) or lspconfig.util.path.dirname(fname)
            end
          })
        end
      })
    end
  }
}
