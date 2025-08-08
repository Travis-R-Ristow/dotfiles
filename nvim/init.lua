require("lazyPlugins")

-- Options
local opt = vim.opt

opt.relativenumber = true
opt.number = true

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.clipboard:append("unnamedplus")

opt.spell = true
opt.spelllang = "en_us"
opt.spelloptions = "camel"

-- KeyBind / Remaps
-- vim.keymap.set("n", "<Home>", "^", { silent = true })
-- vim.keymap.set("n", "<End>", "$", { silent = true })

vim.keymap.set({ "v", "n" }, "y", '"zy')
vim.keymap.set({ "v", "n" }, "p", '"zp')
vim.keymap.set({ "v", "n" }, "x", '"zx')
vim.keymap.set({ "v" }, "Y", '"+y')

vim.keymap.set({ "v", "n" }, "<leader>yl", ":registers<CR>")

vim.keymap.set("n", "grn", vim.lsp.buf.rename)

vim.api.nvim_create_user_command("W", function()
	vim.cmd("w")
end, {})

vim.api.nvim_create_user_command("Q", function()
	vim.cmd("q")
end, {})

vim.api.nvim_create_user_command("Wq", function()
	vim.cmd("wq")
end, {})

vim.api.nvim_create_user_command("WQ", function()
	vim.cmd("wq")
end, {})

vim.api.nvim_create_user_command("Wall", function()
	vim.cmd("wall")
end, {})

vim.cmd("let g:netrw_liststyle = 3")
