-- Colorscheme
vim.cmd.colorscheme(nixCats('colorscheme'))

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
  {
    "nvim-surround",
    for_cat = 'general',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
   {
    "fidget.nvim",
    for_cat = 'general',
    event = "DeferredUIEnter",
    after = function(plugin)
      require('fidget').setup({})
    end,
  },
  {
    "lualine.nvim",
    for_cat = 'general',
    event = "DeferredUIEnter",
    after = function (plugin)
      require('lualine').setup({
        options = {
          icons_enabled = false,
          theme = nixCats('colorscheme'),
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {'filename', path = 1, status = true},
          },
        },
        inactive_sections = {
          lualine_b = {
            {'filename', path = 3, status = true},
          },
          lualine_x = {'filetype'},
        },
        tabline = {
          lualine_a = { 'buffers' },
          lualine_z = { 'tabs' }
        },
      })
    end,
  },
  {
    "which-key.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    colorscheme = nixCats('colorscheme'),
    after = function (plugin)
      require('which-key').setup({})
    end,
  },
}
