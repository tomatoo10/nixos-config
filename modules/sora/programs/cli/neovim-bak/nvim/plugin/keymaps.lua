if vim.g.did_load_keymaps_plugin then
  return
end
vim.g.did_load_keymaps_plugin = true

local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local diagnostic = vim.diagnostic

-- Set main leader to space bar
vim.g.mainleader = ' '

-- Set local leader also to space bar
vim.g.maplocalleader = ' '

-- Yank from current position till end of current line
keymap.set('n', 'Y', 'y$', { silent = true, desc = '[Y]ank to end of line' })

-- <C-y> Yank to system clipboard
vim.keymap.set({'n', 'v'}, '<C-y>', '"+y', {
  noremap = true,
  silent = false, -- Explicitly ensure feedback messages are shown
  desc = 'Yank to system clipboard'
})


-- Toggle the quickfix list (only opens if it is populated)
local function toggle_qf_list()
  local qf_exists = false
  for _, win in pairs(fn.getwininfo() or {}) do
    if win['quickfix'] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd.cclose()
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd.copen()
  end
end

keymap.set('n', '<C-c>', toggle_qf_list, { desc = 'toggle quickfix list' })

local function try_fallback_notify(opts)
  local success, _ = pcall(opts.try)
  if success then
    return
  end
  success, _ = pcall(opts.fallback)
  if success then
    return
  end
  vim.notify(opts.notify, vim.log.levels.INFO)
end

-- Cycle the quickfix and location lists
local function cleft()
  try_fallback_notify {
    try = vim.cmd.cprev,
    fallback = vim.cmd.clast,
    notify = 'Quickfix list is empty!',
  }
end

local function cright()
  try_fallback_notify {
    try = vim.cmd.cnext,
    fallback = vim.cmd.cfirst,
    notify = 'Quickfix list is empty!',
  }
end

keymap.set('n', '[c', cleft, { silent = true, desc = '[c]ycle quickfix left' })
keymap.set('n', ']c', cright, { silent = true, desc = '[c]ycle quickfix right' })
keymap.set('n', '[C', vim.cmd.cfirst, { silent = true, desc = 'first quickfix entry' })
keymap.set('n', ']C', vim.cmd.clast, { silent = true, desc = 'last quickfix entry' })

local function lleft()
  try_fallback_notify {
    try = vim.cmd.lprev,
    fallback = vim.cmd.llast,
    notify = 'Location list is empty!',
  }
end

local function lright()
  try_fallback_notify {
    try = vim.cmd.lnext,
    fallback = vim.cmd.lfirst,
    notify = 'Location list is empty!',
  }
end

keymap.set('n', '[l', lleft, { silent = true, desc = 'cycle [l]oclist left' })
keymap.set('n', ']l', lright, { silent = true, desc = 'cycle [l]oclist right' })
keymap.set('n', '[L', vim.cmd.lfirst, { silent = true, desc = 'first [L]oclist entry' })
keymap.set('n', ']L', vim.cmd.llast, { silent = true, desc = 'last [L]oclist entry' })

local severity = diagnostic.severity

keymap.set('n', '<space>e', function()
  local _, winid = diagnostic.open_float(nil, { scope = 'line' })
  if not winid then
    vim.notify('no diagnostics found', vim.log.levels.INFO)
    return
  end
  vim.api.nvim_win_set_config(winid or 0, { focusable = true })
end, { noremap = true, silent = true, desc = 'diagnostics floating window' })
keymap.set('n', '[d', diagnostic.goto_prev, { noremap = true, silent = true, desc = 'previous [d]iagnostic' })
keymap.set('n', ']d', diagnostic.goto_next, { noremap = true, silent = true, desc = 'next [d]iagnostic' })
keymap.set('n', '[e', function()
  diagnostic.goto_prev {
    severity = severity.ERROR,
  }
end, { noremap = true, silent = true, desc = 'previous [e]rror diagnostic' })
keymap.set('n', ']e', function()
  diagnostic.goto_next {
    severity = severity.ERROR,
  }
end, { noremap = true, silent = true, desc = 'next [e]rror diagnostic' })
keymap.set('n', '[w', function()
  diagnostic.goto_prev {
    severity = severity.WARN,
  }
end, { noremap = true, silent = true, desc = 'previous [w]arning diagnostic' })
keymap.set('n', ']w', function()
  diagnostic.goto_next {
    severity = severity.WARN,
  }
end, { noremap = true, silent = true, desc = 'next [w]arning diagnostic' })
keymap.set('n', '[h', function()
  diagnostic.goto_prev {
    severity = severity.HINT,
  }
end, { noremap = true, silent = true, desc = 'previous [h]int diagnostic' })
keymap.set('n', ']h', function()
  diagnostic.goto_next {
    severity = severity.HINT,
  }
end, { noremap = true, silent = true, desc = 'next [h]int diagnostic' })

local function buf_toggle_diagnostics()
  local filter = { bufnr = api.nvim_get_current_buf() }
  diagnostic.enable(not diagnostic.is_enabled(filter), filter)
end

keymap.set('n', '<space>dt', buf_toggle_diagnostics)

local function toggle_spell_check()
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.opt.spell = not (vim.opt.spell:get())
end

keymap.set('n', '<leader>S', toggle_spell_check, { noremap = true, silent = true, desc = 'toggle [S]pell' })

keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'move [d]own half-page and center' })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'move [u]p half-page and center' })
keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'move DOWN [f]ull-page and center' })
keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'move UP full-page and center' })
