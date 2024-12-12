return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  -- dependencies = {
  --   
  -- },
  config = function()
    require("Comment").setup()
  end
}
