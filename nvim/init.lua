print('Hey, We Building Here! 👷 🏗️');


-- 🥾 BOOTSTRAP LAZY + PLUGINS 🦥

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'neovim/nvim-lspconfig',

  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-path',

  'L3MON4D3/LuaSnip',

  'xiyaowong/transparent.nvim',

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    }
  },

  'rebelot/kanagawa.nvim',

  'prettier/vim-prettier',
})



-- LSP

local lsp                 = require 'lspconfig'
local cmplsp              = require 'cmp_nvim_lsp'
local defaultCapabilities = cmplsp.default_capabilities()

lsp.tsserver.setup {
  capabilities = defaultCapabilities
}

lsp.lua_ls.setup {
  capabilities = defaultCapabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
}

lsp.bashls.setup {
  capabilities = defaultCapabilities
}

-- lsp.ltex.setup {
--   capabilities = defaultCapabilities
-- }



-- CMP

local cmp     = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }
    },
    { { name = 'buffer' } }
  ),
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),

    ['<CR>'] = cmp.mapping.confirm(),
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  })

})



-- FORMATTERS

vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    vim.lsp.buf.format()
    -- vim.lsp.buf.signature_help()
  end
})



-- VIM COMMANDS

vim.g['prettier#autoformat']                = 1
vim.g['prettier#autoformat_require_pragma'] = 0
vim.g['prettier#config#single_quote']       = true
vim.g['prettier#config#print_width']        = 100
vim.g['prettier#config#trailing_comma']     = 'none'


vim.wo.relativenumber = true
vim.opt.expandtab     = true
vim.opt.tabstop       = 2
vim.opt.shiftwidth    = 2


vim.keymap.set('!', 'jj', '<Esc>')
vim.keymap.set('n', 'nh', '<cmd>noh<CR>')

vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')


local telescope = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', telescope.find_files)
vim.keymap.set('n', '<leader>lg', telescope.live_grep)
vim.keymap.set('n', '<leader>tb', telescope.buffers)
vim.keymap.set('n', '<leader>fh', telescope.help_tags)


vim.keymap.set('n', '[g', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']g', vim.diagnostic.goto_next)

vim.keymap.set('n', 'grn', vim.lsp.buf.rename) -- this should already be the default, but wasn't working ???
vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
vim.keymap.set('n', 'gtl', ':copen<CR>')
vim.keymap.set('n', 'gtr', vim.lsp.buf.references)


vim.cmd('colorscheme kanagawa')
