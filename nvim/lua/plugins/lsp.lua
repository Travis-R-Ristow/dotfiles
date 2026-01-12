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
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
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
					vim.keymap.set("n", "gD", vim.lsp.buf.implementation, { buffer = buf })
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = buf })
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

			vim.lsp.config("ts_ls", {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
				capabilities = capabilities,
				root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
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
			})

			vim.lsp.config("eslint", {
				cmd = { "vscode-eslint-language-server", "--stdio" },
				capabilities = capabilities,
				root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yaml", ".eslintrc.yml", "eslint.config.js", "eslint.config.mjs", "package.json" },
				filetypes = {
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"typescript.tsx",
					"javascript.jsx",
				},
				settings = {
					validate = "on",
					packageManager = nil,
					useESLintClass = false,
					experimental = { useFlatConfig = false },
					codeActionOnSave = { enable = false, mode = "all" },
					format = true,
					quiet = false,
					onIgnoredFiles = "off",
					rulesCustomizations = {},
					run = "onType",
					problems = { shortenToSingleLine = false },
					nodePath = "",
					workingDirectory = { mode = "auto" },
				},
				on_attach = function(client, buf)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = buf,
						callback = function()
							local params = {
								command = "eslint.applyAllFixes",
								arguments = {
									{
										uri = vim.uri_from_bufnr(buf),
										version = vim.lsp.util.buf_versions[buf],
									},
								},
							}
							client:request_sync("workspace/executeCommand", params, 3000, buf)
						end,
					})
				end,
			})

			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				capabilities = capabilities,
				root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
				settings = {
					Lua = {
						diagnostics = {
							globals = read_luacheck_globals(),
						},
					},
				},
			})

			vim.lsp.enable({ "ts_ls", "eslint", "lua_ls" })
		end,
	},
}
