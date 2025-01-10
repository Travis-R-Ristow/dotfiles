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
			"Hoffs/omnisharp-extended-lsp.nvim",
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
				["omnisharp"] = function()
					lspconfig["omnisharp"].setup({
						cmd = {
							"/Users/TRistow/.local/share/nvim/mason/bin/omnisharp",
							"--languageserver",
							"--hostPID",
							tostring(vim.fn.getpid()),
						},
						handlers = {
							["textDocument/definition"] = require("omnisharp_extended").handler,
						},
						enable_editorconfig_support = true,
					})
				end,
			})
		end,
	},
}
