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

    vim.keymap.set("n", "z=", function()
      local word = vim.fn.expand("<cword>")
      local suggestions = vim.fn.spellsuggest(word, 5)
      if #suggestions == 0 then
        vim.notify("No spelling suggestions", vim.log.levels.INFO)
        return
      end
      vim.ui.select(suggestions, { prompt = "Spelling: " }, function(choice)
        if choice then
          vim.cmd("normal! ciw" .. choice)
          vim.cmd("stopinsert")
        end
      end)
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
