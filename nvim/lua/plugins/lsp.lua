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
					"roslyn",
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
		dependencies = {
			"mfussenegger/nvim-dap",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
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
			local dap = require("dap")
			local dapUi = require("dapui")

			dap.adapters.coreclr = {
				type = "executable",
				command = "/opt/netcoredbg/netcoredbg/bin/netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "attach process",
					request = "attach",
					processId = function()
						return require("dap.utils").pick_process({
							filter = function(proc)
								return proc.name:match("dotnet")
							end,
						})
					end,
				},
			}

			dapUi.setup()

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(event)
					local buf = event.buf

					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf })
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buf })
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buf })
					vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { buffer = buf })
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf })
					vim.keymap.set("n", "<F5>", dap.continue, { buffer = buf })
					vim.keymap.set("n", "<F10>", dap.step_over, { buffer = buf })
					vim.keymap.set("n", "<F11>", dap.step_into, { buffer = buf })
					vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { buffer = buf })
					vim.keymap.set("n", "<leader>dr", dap.repl.open, { buffer = buf })
					vim.keymap.set("n", "<leader>dbu", dapUi.toggle, { buffer = buf })

					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.cs" },
						command = ":!dotnet csharpier %",
					})
				end,
			})

			local servers = {
				ts_ls = {
					capabilities = capabilities,
					root_dir = function(fname)
						return vim.fs.dirname(
							vim.fs.find(
								{ "tsconfig.json", "package.json", "jsconfig.json", ".git" },
								{ path = fname, upward = true }
							)[1]
						)
					end,
					init_options = {
						hostInfo = "neovim",
						preferences = {
							importModuleSpecifierPreference = "relative",
							includePackageJsonAutoImports = "auto",
							includeCompletionsForModuleExports = true,
						},
					},
					settings = {
						typescript = {
							preferences = {
								includePackageJsonAutoImports = "auto",
							},
							suggest = {
								autoImports = true,
							},
							exclude = {
								"**/node_modules/**",
								"**/dist/**",
								"**/build/**",
							},
							enableProjectDiagnostics = true,
							disableAutomaticTypingAcquisition = false,
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							enableProjectDiagnostics = true,
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
					flags = {
						debounce_text_changes = 150,
					},
				},
				eslint = {
					capabilities = capabilities,
					filetypes = {
						"javascript",
						"typescript",
						"javascriptreact",
						"typescriptreact",
						"typescript.tsx",
						"javascript.jsx",
					},
					on_attach = function(client, buf)
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = buf,
							command = "EslintFixAll",
						})
					end,
				},
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
