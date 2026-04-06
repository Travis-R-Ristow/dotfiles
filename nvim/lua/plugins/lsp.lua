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

local dotnet_run_job_id = nil
local dotnet_run_pid = nil

local function kill_dotnet_run()
	if dotnet_run_pid then
		vim.fn.jobstop(dotnet_run_job_id)
		os.execute("kill -9 " .. dotnet_run_pid .. " 2>/dev/null")
		local children = vim.fn.systemlist("pgrep -P " .. dotnet_run_pid)
		for _, child_pid in ipairs(children) do
			os.execute("kill -9 " .. child_pid .. " 2>/dev/null")
		end
		dotnet_run_job_id = nil
		dotnet_run_pid = nil
		vim.notify("Killed dotnet process", vim.log.levels.INFO)
	else
		vim.notify("No dotnet process running", vim.log.levels.WARN)
	end
end

local function get_dotnet_run_status()
	if dotnet_run_pid then
		local result = vim.fn.system("ps -p " .. dotnet_run_pid .. " -o pid=")
		if vim.trim(result) ~= "" then
			return "running (PID: " .. dotnet_run_pid .. ")"
		end
	end
	return "not running"
end

local function find_csproj_files()
	local cwd = vim.fn.getcwd()
	local files = vim.fn.globpath(cwd, "**/*.csproj", false, true)
	return files
end

local function get_launch_profiles(csproj_path)
	local project_dir = vim.fn.fnamemodify(csproj_path, ":h")
	local launch_settings_path = project_dir .. "/Properties/launchSettings.json"
	local file = io.open(launch_settings_path, "r")
	if not file then
		return {}
	end
	local content = file:read("*a")
	file:close()
	local ok, parsed = pcall(vim.fn.json_decode, content)
	if not ok or not parsed or not parsed.profiles then
		return {}
	end
	local profiles = {}
	for name, _ in pairs(parsed.profiles) do
		table.insert(profiles, name)
	end
	table.sort(profiles)
	return profiles
end

local function pick_csproj(callback)
	local files = find_csproj_files()
	if #files == 0 then
		vim.notify("No .csproj files found", vim.log.levels.ERROR)
		return
	end
	local cwd = vim.fn.getcwd()
	local display_files = {}
	for _, f in ipairs(files) do
		local display = f:gsub(cwd .. "/", "")
		table.insert(display_files, display)
	end
	vim.ui.select(display_files, { prompt = "Select .csproj:" }, function(choice, idx)
		if choice then
			callback(files[idx])
		end
	end)
end

local function pick_launch_profile(csproj_path, callback)
	local profiles = get_launch_profiles(csproj_path)
	if #profiles == 0 then
		vim.notify("No launch profiles found for this project", vim.log.levels.WARN)
		callback(nil)
		return
	end
	vim.ui.select(profiles, { prompt = "Select launch profile:" }, function(choice)
		callback(choice)
	end)
end

local function find_dotnet_child_pid(parent_pid)
	local child_pids = vim.fn.systemlist("pgrep -P " .. parent_pid)
	for _, pid_str in ipairs(child_pids) do
		local pid = tonumber(pid_str)
		if pid then
			local proc_info = vim.fn.system("ps -p " .. pid .. " -o comm=")
			if proc_info:match("dotnet") then
				return pid
			end
		end
	end
	if #child_pids > 0 then
		return tonumber(child_pids[#child_pids])
	end
	return nil
end

local dotnet_project_cwd = nil

local function poll_and_attach(attempt)
	local max_attempts = 50
	attempt = attempt or 1

	if not dotnet_run_pid then
		vim.notify("dotnet process stopped", vim.log.levels.WARN)
		return
	end

	local target_pid = find_dotnet_child_pid(dotnet_run_pid)

	if target_pid then
		vim.notify("Attaching to PID: " .. target_pid, vim.log.levels.INFO)
		require("dap").run({
			type = "coreclr",
			name = "attach",
			request = "attach",
			processId = target_pid,
			justMyCode = false,
			cwd = dotnet_project_cwd,
		})
	elseif attempt < max_attempts then
		vim.defer_fn(function()
			poll_and_attach(attempt + 1)
		end, 500)
	else
		vim.notify("Timeout waiting for dotnet process", vim.log.levels.ERROR)
	end
end

local function run_dotnet_and_attach(csproj_path, launch_profile)
	kill_dotnet_run()

	local project_dir = vim.fn.fnamemodify(csproj_path, ":h")
	dotnet_project_cwd = project_dir

	local cmd = "dotnet run --project " .. vim.fn.shellescape(csproj_path) .. " -c Debug"
	if launch_profile then
		cmd = cmd .. " -lp " .. vim.fn.shellescape(launch_profile)
	end

	dotnet_run_job_id = vim.fn.jobstart(cmd, {
		cwd = project_dir,
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify("dotnet run exited with code " .. code, vim.log.levels.WARN)
			end
			dotnet_run_job_id = nil
			dotnet_run_pid = nil
		end,
	})

	dotnet_run_pid = vim.fn.jobpid(dotnet_run_job_id)
	vim.notify("Started dotnet run (PID: " .. dotnet_run_pid .. ") in " .. project_dir, vim.log.levels.INFO)
	vim.notify("Waiting 5 seconds for app to start...", vim.log.levels.INFO)

	vim.defer_fn(function()
		poll_and_attach(1)
	end, 5000)
end

vim.api.nvim_create_user_command("DotnetRunStatus", function()
	vim.notify("Dotnet run: " .. get_dotnet_run_status(), vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("DotnetRunKill", function()
	kill_dotnet_run()
end, {})

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

			dap.set_log_level("TRACE")

			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "launch (pick csproj + profile)",
					request = "attach",
					processId = function()
						local co = coroutine.running()
						pick_csproj(function(csproj_path)
							if not csproj_path then
								coroutine.resume(co, nil)
								return
							end
							pick_launch_profile(csproj_path, function(profile)
								run_dotnet_and_attach(csproj_path, profile)
								coroutine.resume(co, nil)
							end)
						end)
						return coroutine.yield()
					end,
				},
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
					vim.keymap.set("n", "<S-F5>", dap.terminate, { buffer = buf })
					vim.keymap.set("n", "<F10>", dap.step_over, { buffer = buf })
					vim.keymap.set("n", "<F11>", dap.step_into, { buffer = buf })
					vim.keymap.set("n", "<S-F11>", dap.step_out, { buffer = buf })
					vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { buffer = buf })
					vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { buffer = buf })
					vim.keymap.set("n", "<leader>dbu", dapUi.toggle, { buffer = buf })
					vim.keymap.set("n", "<leader>dk", kill_dotnet_run, { buffer = buf })
					vim.keymap.set("n", "<leader>ds", function()
						vim.notify("Dotnet run: " .. get_dotnet_run_status(), vim.log.levels.INFO)
					end, { buffer = buf })

					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.cs" },
						command = ":!dotnet csharpier %",
					})
				end,
			})

			vim.lsp.config("ts_ls", {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
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
				root_markers = {
					".eslintrc",
					".eslintrc.js",
					".eslintrc.json",
					".eslintrc.yaml",
					".eslintrc.yml",
					"eslint.config.js",
					"eslint.config.mjs",
					"package.json",
				},
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
					workingDirectory = { mode = "location" },
				},
				on_attach = function(client, buf)
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = buf,
						callback = function()
							if not vim.g.format_changed_only then
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
								return
							end

							local gitsigns = package.loaded.gitsigns
							if not gitsigns then
								return
							end

							local hunks = gitsigns.get_hunks(buf)
							if not hunks or #hunks == 0 then
								return
							end

							local changed_lines = {}
							for _, hunk in ipairs(hunks) do
								for i = hunk.added.start, hunk.added.start + hunk.added.count - 1 do
									changed_lines[i] = true
								end
							end

							local diagnostics = vim.diagnostic.get(buf)
							for _, diag in ipairs(diagnostics) do
								if changed_lines[diag.lnum + 1] and diag.source == "eslint" then
									vim.lsp.buf.code_action({
										context = { diagnostics = { diag }, only = { "quickfix" } },
										apply = true,
									})
								end
							end
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
