return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {

  },
  config = function ()
    local treesitter = require("nvim-treesitter.configs")
    treesitter.setup({
      indent = { enable = true },
      autotag = { enable = true },
      ensure_installed = {
        "javascript",
        "typescript",
        "html",
        "css",
        "tsx",
        "lua",
        "graphql",
        "markdown"
      },
    })
  end
}
