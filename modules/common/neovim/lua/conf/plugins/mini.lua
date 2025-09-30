return {
  "mini.nvim",
  for_cat = 'general',

  version = false,
  config = function()
    -- Text editing
    require("mini.ai").setup()
    require("mini.operators").setup()
    require("mini.surround").setup()

    -- General Workflow
    require("mini.picks").setup()
    require("mini.files").setup()
    require("mini.bracketed").setup()
    require("mini.clue").setup()
    require("mini.basics").setup()

    -- Appearance
    require("mini.icons").setup()
  end,
}
