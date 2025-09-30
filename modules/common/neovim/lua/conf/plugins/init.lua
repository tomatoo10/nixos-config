-- Colorscheme
local colorscheme = nixCats('colorscheme')
vim.cmd.colorscheme(colorscheme)

if colorscheme == "sonokai" then
  vim.o.termguicolors = false
else
  vim.o.termguicolors = true
end

-- Notify
local ok, notify = pcall(require, "notify")
if ok then
  notify.setup({
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  })
  vim.notify = notify
  -- Dismiss notification with escape
  vim.keymap.set("n", "<Esc>", function()
    notify.dismiss({ silent = true, })
  end)
end

if nixCats('general.notlazy') then
  -- not lazy loaded
end

require('lze').load {
  { import = "conf.plugins.fzf", },
  { import = "conf.plugins.treesitter", },
  { import = "conf.plugins.multicursor", },
  { import = "conf.plugins.ui", },
  { import = "conf.plugins.mini", },
  {
    "nvim-surround",
    for_cat = 'general',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
  {
    "no-neck-pain.nvim",
    for_cat = 'general',
    load = function(name)
      vim.cmd.packadd(name)
    end,
    after = function(plugin)
      require('no-neck-pain').setup({
        width = 120, -- Set your desired width here
        -- Add other configuration options as needed
      })
    end,
    event = "DeferredUIEnter",
  },
}
