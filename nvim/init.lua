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

  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-path',

  'L3MON4D3/LuaSnip',

  'nvim-treesitter/nvim-treesitter',

  'windwp/nvim-ts-autotag',
  'windwp/nvim-autopairs',
  'pedro757/emmet',

  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'BurntSushi/ripgrep',
      'nvim-lua/plenary.nvim',
      'sharkdp/fd',
    }
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },

  'rebelot/kanagawa.nvim',

  'xiyaowong/transparent.nvim',

  'prettier/vim-prettier',
})



-- LSP

local lsp                 = require 'lspconfig'
local lspconfigs          = require 'lspconfig.configs'
local cmplsp              = require 'cmp_nvim_lsp'
local defaultCapabilities = cmplsp.default_capabilities()

lsp.tsserver.setup {
  capabilities = defaultCapabilities,
  init_options = {
    preferences = {
      importModuleSpecifierPreference = 'relative',
    }
  }
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

local useSnippets = vim.lsp.protocol.make_client_capabilities()
useSnippets.textDocument.completion.completionItem.snippetSupport = true

lsp.html.setup {
  capabilities = useSnippets,
  init_options = {
    provideFormatter = false,
    configurationSection = { "html", "css", "javascript" },
    embeddedLanguages = {
      css = true,
      javascript = true
    }
  }
}

if not lspconfigs.ls_emmet then
  lspconfigs.ls_emmet = {
    default_config = {
      cmd = { 'ls_emmet', '--stdio' },
      filetypes = {
        'html',
        'css',
        'typescriptreact',
        'xml',
        'xsl',
      },
      root_dir = function()
        return vim.loop.cwd()
      end,
      settings = {},
    },
  }
end
lsp.ls_emmet.setup {
  capabilities = useSnippets,
}

lsp.cssls.setup {
  capabilities = defaultCapabilities,
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



-- TREESITTER

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }

require 'nvim-treesitter'.setup {
  ensure_installed = { 'html', 'css', 'markdown', 'lua' },
  autotag = {
    enable = true
  }
  -- highlight = {
  --   enable = true
  -- }
}

require 'nvim-ts-autotag'.setup {}

require 'nvim-autopairs'.setup({
  disable_filetype = { "TelescopePrompt" },
})



-- TELESCOPE

-- local fb_actions = require "telescope._extensions.file_browser.actions"
local telescope = require 'telescope'

telescope.setup({
  defaults = {
    file_ignore_patterns = { "node_modules" }
  },
  extensions = {
    file_browser = {
      -- hijack_netrw = true,
      -- mappings = {   -- DEFAULTS
      --   ["i"] = {
      --     ["<A-c>"] = fb_actions.create,
      --     ["<S-CR>"] = fb_actions.create_from_prompt,
      --     ["<A-r>"] = fb_actions.rename,
      --     ["<A-m>"] = fb_actions.move,
      --     ["<A-y>"] = fb_actions.copy,
      --     ["<A-d>"] = fb_actions.remove,
      --     ["<C-o>"] = fb_actions.open,
      --     ["<C-g>"] = fb_actions.goto_parent_dir,
      --     ["<C-e>"] = fb_actions.goto_home_dir,
      --     ["<C-w>"] = fb_actions.goto_cwd,
      --     ["<C-t>"] = fb_actions.change_cwd,
      --     ["<C-f>"] = fb_actions.toggle_browser,
      --     ["<C-h>"] = fb_actions.toggle_hidden,
      --     ["<C-s>"] = fb_actions.toggle_all,
      --     ["<bs>"] = fb_actions.backspace,
      --   },
      --   ["n"] = {
      --     ["c"] = fb_actions.create,
      --     ["r"] = fb_actions.rename,
      --     ["m"] = fb_actions.move,
      --     ["y"] = fb_actions.copy,
      --     ["d"] = fb_actions.remove,
      --     ["o"] = fb_actions.open,
      --     ["g"] = fb_actions.goto_parent_dir,
      --     ["e"] = fb_actions.goto_home_dir,
      --     ["w"] = fb_actions.goto_cwd,
      --     ["t"] = fb_actions.change_cwd,
      --     ["f"] = fb_actions.toggle_browser,
      --     ["h"] = fb_actions.toggle_hidden,
      --     ["s"] = fb_actions.toggle_all,
      --   },
      -- }
    }
  }
})
telescope.load_extension 'file_browser'



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
vim.keymap.set('n', '<C-o>', '<C-o>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

local telescopeActions = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', telescopeActions.find_files)
vim.keymap.set('n', '<leader>lg', telescopeActions.live_grep)
vim.keymap.set('n', '<leader>lgs', telescopeActions.grep_string)
vim.keymap.set('n', '<leader>rf', telescopeActions.oldfiles)
local function grep_with_selection()
  vim.cmd('noau normal! "vy"')
  local search_text = vim.fn.getreg('v')
  telescopeActions.live_grep({
    default_text = search_text,
  })
end
vim.keymap.set('v', '<leader>lg', grep_with_selection)
vim.keymap.set('n', '<leader>jl', telescopeActions.jumplist)
vim.keymap.set('n', '<leader>ml', telescopeActions.marks)

vim.keymap.set('n', '[g', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']g', vim.diagnostic.goto_next)

vim.keymap.set('n', 'grn', vim.lsp.buf.rename) -- this should already be the default, but wasn't working ???
vim.keymap.set('n', 'gd', telescopeActions.lsp_definitions)
vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition)
vim.keymap.set('n', 'gtr', vim.lsp.buf.references)

vim.keymap.set('n', '<leader>ls', ':!ls %:p:h<CR>')
vim.keymap.set("n", "<leader>fb", ':Telescope file_browser path=%:p:h<CR>')

vim.keymap.set('n', 'gtl', ':copen<CR>')
vim.keymap.set('n', 'qlc', ':cclose<CR>')

vim.cmd('colorscheme kanagawa')
