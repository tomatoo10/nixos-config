if vim.g.did_load_completion_plugin then
  return
end
vim.g.did_load_completion_plugin = true

local cmp = require('cmp')
local luasnip = require('luasnip')

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local function has_words_before()
  local unpack_ = unpack or table.unpack
  local line, col = unpack_(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

---@param source string|table
local function complete_with_source(source)
  if type(source) == 'string' then
    cmp.complete { config = { sources = { { name = source } } } }
  elseif type(source) == 'table' then
    cmp.complete { config = { sources = { source } } }
  end
end

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
    -- autocomplete = false,
  },
  formatting = {
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ['<C-B>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(-4)
      else
        complete_with_source('buffer')
      end
    end, { 'i', 'c', 's' }),
    ['<C-b>'] = cmp.mapping(function(_)
      if cmp.visible() then
        cmp.scroll_docs(4)
      else
        complete_with_source('path')
      end
    end, { 'i', 'c', 's' }),
    -- Cycle with Ctrl+F
    ['<C-f>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      -- expand_or_jumpable(): Jump outside the snippet region
      -- expand_or_locally_jumpable(): Only jump inside the snippet region
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    -- Cycle backwards with Ctrl+Shift+F
    ['<C-F>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 'c', 's' }),
    -- Deny completion with Ctrl+e
    ['<C-e>'] = cmp.mapping(function(_)
        cmp.abort()
    end, { 'i', 'c', 's' }),
    -- Accept completion with Tab or Ctrl+I
    ['<Tab>'] = cmp.mapping.confirm {
      select = true,
    },
  },
  sources = cmp.config.sources {
    -- The insertion order influences the priority of the sources
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'nvim_lsp_signature_help', keyword_length = 3 },
    { name = 'buffer' },
    { name = 'path' },
  },
  enabled = function()
    return vim.bo[0].buftype ~= 'prompt'
  end,
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
}

cmp.setup.filetype('lua', {
  sources = cmp.config.sources {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'path' },
  },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'nvim_lsp_document_symbol', keyword_length = 3 },
    { name = 'buffer' },
  },
  view = {
    entries = { name = 'wildmenu', separator = '|' },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources {
    { name = 'cmdline' },
    { name = 'path' },
  },
})

-- Don't use this i guess
-- vim.keymap.set({ 'i', 'c', 's' }, '<C-n>', cmp.complete, { noremap = false, desc = '[cmp] complete' })
-- vim.keymap.set({ 'i', 'c', 's' }, '<C-f>', function()
--   complete_with_source('path')
-- end, { noremap = false, desc = '[cmp] path' })
-- vim.keymap.set({ 'i', 'c', 's' }, '<C-o>', function()
--   complete_with_source('nvim_lsp')
-- end, { noremap = false, desc = '[cmp] lsp' })
-- vim.keymap.set({ 'c' }, '<C-h>', function()
-- vim.keymap.set({ 'c' }, '<C-c>', function()
--   complete_with_source('cmdline')
-- end, { noremap = false, desc = '[cmp] cmdline' })
