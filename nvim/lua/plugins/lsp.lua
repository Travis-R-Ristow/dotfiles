local function read_luacheck_globals()
  local globals = {}
  local luacheckrc = io.open(vim.fn.stdpath("config") .. "/.luacheckrc", "r")
  if luacheckrc then
    for line in luacheckrc:lines() do
      for global in line:gmatch('"%s*(%w+)%s*"') do
        table.insert(globals, global)
      end
    end
    luacheckrc:close()
  end
  return globals
end

return {
  {
    "mason-org/mason.nvim",
    config = function()
      local mason = require("mason")

      mason.setup({
        ensure_installed = {
          "lua-language-server",
          "typescript-language-server",
          "html-lsp",
          "css-lsp",
          "eslint",
        },
        registries = {
          "github:mason-org/mason-registry",
          "github:Crashdummyy/mason-registry",
        },
      })
    end,
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(event)
          local buf = event.buf

          vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { buffer = buf })
          vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { buffer = buf })
          vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { buffer = buf })
          vim.keymap.set("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { buffer = buf })
          vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { buffer = buf })
        end,
      })

      local servers = {
        biome = {
          capabilities = capabilities,
          root_dir = function(fname)
            return vim.fs.dirname(
              vim.fs.find(
                { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
                { path = fname, upward = true }
              )[1]
            )
          end,

        },
        -- ts_ls = {
        -- 	capabilities = capabilities,
        -- 	root_dir = function(fname)
        -- 		return vim.fs.dirname(
        -- 			vim.fs.find(
        -- 				{ "tsconfig.json", "package.json", "jsconfig.json", ".git" },
        -- 				{ path = fname, upward = true }
        -- 			)[1]
        -- 		)
        -- 	end,
        -- 	init_options = {
        -- 		hostInfo = "neovim",
        -- 		preferences = {
        -- 			importModuleSpecifierPreference = "relative",
        -- 			includePackageJsonAutoImports = "auto",
        -- 			includeCompletionsForModuleExports = true,
        -- 		},
        -- 	},
        -- 	settings = {
        -- 		typescript = {
        -- 			preferences = {
        -- 				includePackageJsonAutoImports = "auto",
        -- 			},
        -- 			suggest = {
        -- 				autoImports = true,
        -- 			},
        -- 			exclude = {
        -- 				"**/node_modules/**",
        -- 				"**/dist/**",
        -- 				"**/build/**",
        -- 			},
        -- 			enableProjectDiagnostics = true,
        -- 			disableAutomaticTypingAcquisition = false,
        -- 			inlayHints = {
        -- 				includeInlayParameterNameHints = "all",
        -- 				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        -- 				includeInlayFunctionParameterTypeHints = true,
        -- 				includeInlayVariableTypeHints = true,
        -- 				includeInlayPropertyDeclarationTypeHints = true,
        -- 				includeInlayFunctionLikeReturnTypeHints = true,
        -- 				includeInlayEnumMemberValueHints = true,
        -- 			},
        -- 		},
        -- 		javascript = {
        -- 			enableProjectDiagnostics = true,
        -- 			inlayHints = {
        -- 				includeInlayParameterNameHints = "all",
        -- 				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        -- 				includeInlayFunctionParameterTypeHints = true,
        -- 				includeInlayVariableTypeHints = true,
        -- 				includeInlayPropertyDeclarationTypeHints = true,
        -- 				includeInlayFunctionLikeReturnTypeHints = true,
        -- 				includeInlayEnumMemberValueHints = true,
        -- 			},
        -- 		},
        -- 	},
        -- 	flags = {
        -- 		debounce_text_changes = 150,
        -- 	},
        -- },
        -- eslint = {
        -- 	capabilities = capabilities,
        -- 	filetypes = {
        -- 		"javascript",
        -- 		"typescript",
        -- 		"javascriptreact",
        -- 		"typescriptreact",
        -- 		"typescript.tsx",
        -- 		"javascript.jsx",
        -- 	},
        -- 	on_attach = function(client, buf)
        -- 		vim.api.nvim_create_autocmd("BufWritePre", {
        -- 			buffer = buf,
        -- 			command = "EslintFixAll",
        -- 		})
        -- 	end,
        -- },
        lua_ls = {
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = read_luacheck_globals(),
              },
            },
          },
        },
      }

      for server_name, config in pairs(servers) do
        lspconfig[server_name].setup(config)
      end
    end,
  },
}
