return {
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
    after = function(plugin)
      require('lualine').setup({
        options = {
          icons_enabled = false,
          theme = nixCats('colorscheme'),
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            { 'filename', path = 1, status = true },
          },
        },
        inactive_sections = {
          lualine_b = {
            { 'filename', path = 3, status = true },
          },
          lualine_x = { 'filetype' },
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
    after = function(plugin)
      require('which-key').setup({})
    end,
  },

}
