local function read_luacheck_globals()
	local globals = {}
	local luacheckrc = io.open(".luacheckrc", "r")
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
				automatic_installation = {
					"lua_ls",
					"cspell",
				},
				ensure_installed = {
					"ts_ls",
					"html",
					"cssls",
					"lua_ls",
					"graphql",
				},
			})
		end,
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
			local mason_lspconfig = require("mason-lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function()
					vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>")
				end,
			})

			mason_lspconfig.setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,
				["ts_ls"] = function()
					lspconfig.ts_ls.setup({
						capabilities = capabilities,
						root_dir = function(fname)
							return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
						end,
						init_options = {
							preferences = {
								importModuleSpecifierPreference = "relative",
							},
						},
					})
				end,
				["eslint"] = function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
						filetype = {
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
					})
				end,
				["lua_ls"] = function(server_name)
					lspconfig[server_name].setup({
						settings = {
							Lua = {
								diagnostics = {
									globals = read_luacheck_globals(),
								},
							},
						},
					})
				end,
				["omnisharp"] = function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
						root_dir = function(fname)
							return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
						end,
						cmd = {
							"/Users/TRistow/.local/share/nvim/mason/bin/omnisharp",
							"--languageserver",
							"--hostPID",
							tostring(vim.fn.getpid()),
						},
						on_attach = function(client, buf)
							client.server_capabilities.semanticTokensProvider = nil

							vim.api.nvim_create_autocmd("BufWritePost", {
								buffer = buf,
								command = ":!dotnet csharpier %",
							})
						end,
						-- handlers = {
						-- 	["textDocument/definition"] = require("omnisharp_extended").handler,
						-- },
						settings = {
							FormattingOptions = {
								-- Enables support for reading code style, naming convention and analyzer
								-- settings from .editorconfig.
								EnableEditorConfigSupport = true,
								-- Specifies whether 'using' directives should be grouped and sorted during
								-- document formatting.
								OrganizeImports = true,
							},
							MsBuild = {
								-- If true, MSBuild project system will only load projects for files that
								-- were opened in the editor. This setting is useful for big C# codebases
								-- and allows for faster initialization of code navigation features only
								-- for projects that are relevant to code that is being edited. With this
								-- setting enabled OmniSharp may load fewer projects and may thus display
								-- incomplete reference lists for symbols.
								LoadProjectsOnDemand = false,
							},
							RoslynExtensionsOptions = {
								-- Enables support for roslyn analyzers, code fixes and rulesets.
								-- EnableAnalyzersSupport = true,
								-- Enables support for showing unimported types and unimported extension
								-- methods in completion lists. When committed, the appropriate using
								-- directive will be added at the top of the current file. This option can
								-- have a negative impact on initial completion responsiveness,
								-- particularly for the first few completion sessions after opening a
								-- solution.
								EnableImportCompletion = true,
								-- Only run analyzers against open files when 'enableRoslynAnalyzers' is
								-- true
								AnalyzeOpenDocumentsOnly = false,
								EnableAnalyzersSupport = true,
							},
							Sdk = {
								-- Specifies whether to include preview versions of the .NET SDK when
								-- determining which version to use for project loading.
								IncludePrereleases = true,
							},
						},
					})
				end,
			})
		end,
	},
}
