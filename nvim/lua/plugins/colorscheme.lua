return {
  "rose-pine/neovim",
  name = "rose-pine" ,
  config = function()
    require("rose-pine").setup({
      variant = "moon",
      dark_variant = "moon",
      dim_inactive_windows = true,
      extend_background_behind_borders = true,
      enable = {
        terminal = true
      },
      styles = {
        transparency = true
      },
      palette = {},
      groups = {},
      highlight_groups = {},
      before_highlight = function() end,
    })

    vim.cmd("colorscheme rose-pine-moon")
  end
}
