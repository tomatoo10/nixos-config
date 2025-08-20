vim.loader.enable()

local cmd = vim.cmd
local opt = vim.o

if not vim.o.path:find('**', 1, true) then
  opt.path = vim.o.path .. ',**'
end

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.lazyredraw = false -- Lazy Redraw screen when macros
opt.showmatch = true -- Highlight matching parentheses, etc
opt.incsearch = true

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.foldenable = true
opt.history = 2000
opt.nrformats = 'bin,hex' -- 'octal'
opt.undofile = true
opt.cmdheight = 0

-- Change the highlighting feature when searching

local hl_ns = vim.api.nvim_create_namespace('search')
local hlsearch_group = vim.api.nvim_create_augroup('hlsearch_group', { clear = true })

vim.api.nvim_create_autocmd('CursorMoved', {
  group = hlsearch_group,
  callback = function()
    vim.on_key(function(char)
      if vim.fn.mode() == "n" then
        local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
        if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
      end
    end, vim.api.nvim_create_namespace "auto_hlsearch")
  end,
})

-- Native plugins
cmd.filetype('plugin', 'indent', 'on')
cmd.packadd('cfilter') -- Allows filtering the quickfix list with :cfdo

-- let sqlite.lua (which some plugins depend on) know where to find sqlite
vim.g.sqlite_clib_path = require('luv').os_getenv('LIBSQLITE')
