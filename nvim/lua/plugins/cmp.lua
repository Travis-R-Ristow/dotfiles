return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp"
    }
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()

    local spell_word = nil

    local spell_source = {}

    function spell_source:get_keyword_pattern()
      return [[\k*]]
    end

    function spell_source:complete(_, callback)
      if not spell_word then
        callback({})
        return
      end
      local suggestions = vim.fn.spellsuggest(spell_word, 5)
      local items = {}
      for _, suggestion in ipairs(suggestions) do
        table.insert(items, { label = suggestion })
      end
      callback(items)
    end

    cmp.register_source("spell", spell_source)

    vim.keymap.set("n", "z=", function()
      spell_word = vim.fn.expand("<cword>")
      local keys = vim.api.nvim_replace_termcodes("ciw", true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
      vim.defer_fn(function()
        cmp.complete({ config = { sources = { { name = "spell" } } } })
      end, 50)
    end, { desc = "Spelling suggestions" })

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect"
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" }
      })
    })
  end
}
