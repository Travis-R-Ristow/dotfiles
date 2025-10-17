-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

require("lazyPlugins")

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

vim.keymap.set("n", "<C-Left>", "^")
vim.keymap.set("n", "<C-Right>", "$")

vim.keymap.set({ "v", "n" }, "y", '"*y')
vim.keymap.set({ "v", "n" }, "p", '"*p')
vim.keymap.set({ "v", "n" }, "x", '"*x')

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

vim.api.nvim_create_user_command("Chrome", function()
	vim.cmd("open -a 'Google Chrome'")
end, {})
