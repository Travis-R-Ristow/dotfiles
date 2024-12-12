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



vim.cmd("let g:netrw_liststyle = 3")
