if vim.g.did_load_autocommands_plugin then
  return
end
vim.g.did_load_autocommands_plugin = true

local api = vim.api

local tempdirgroup = api.nvim_create_augroup('tempdir', { clear = true })
-- Do not set undofile for files in /tmp
api.nvim_create_autocmd('BufWritePre', {
  pattern = '/tmp/*',
  group = tempdirgroup,
  callback = function()
    vim.cmd.setlocal('noundofile')
  end,
})

-- LSP
local keymap = vim.keymap

local function preview_location_callback(_, result)
  if result == nil or vim.tbl_isempty(result) then
    return nil
  end
  local buf, _ = vim.lsp.util.preview_location(result[1])
  if buf then
    local cur_buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].filetype = vim.bo[cur_buf].filetype
  end
end

local function peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, preview_location_callback)
end

local function peek_type_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/typeDefinition', params, preview_location_callback)
end

--- Don't create a comment string when hitting <Enter> on a comment line
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('DisableNewLineAutoCommentString', {}),
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { 'c', 'r', 'o' }
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Attach plugins
    require('nvim-navic').attach(client, bufnr)

    vim.cmd.setlocal('signcolumn=yes')
    vim.bo[bufnr].bufhidden = 'hide'

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local function desc(description)
      return { noremap = true, silent = true, buffer = bufnr, desc = description }
    end

    -- LSP Keybinds 

    -- LSP Keybinds (LazyVim style)

    keymap.set("n", "<leader>cl", "<cmd>LspInfo<cr>", desc("LSP Info"))

    keymap.set("n", "gd", vim.lsp.buf.definition,      desc("Goto Definition"))
    keymap.set("n", "gr", vim.lsp.buf.references,      desc("References"))
    keymap.set("n", "gI", vim.lsp.buf.implementation,  desc("Goto Implementation"))
    keymap.set("n", "gy", vim.lsp.buf.type_definition, desc("Goto Type Definition"))
    keymap.set("n", "gD", vim.lsp.buf.declaration,     desc("Goto Declaration"))

    keymap.set("n", "K",  vim.lsp.buf.hover,           desc("Hover"))
    keymap.set("n", "gK", vim.lsp.buf.signature_help,  desc("Signature Help"))
    keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, desc("Signature Help (insert)"))

    keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, desc("Code Action"))
    keymap.set("n", "<leader>cc", vim.lsp.codelens.run,    desc("Run CodeLens"))
    keymap.set("n", "<leader>cC", vim.lsp.codelens.refresh, desc("Refresh CodeLens"))

    keymap.set("n", "<leader>cR", vim.lsp.buf.rename, desc("Rename File")) -- optional, LazyVim has file rename helper
    keymap.set("n", "<leader>cr", vim.lsp.buf.rename, desc("Rename Symbol"))
    keymap.set("n", "<leader>cA", function()
      vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } }
    end, desc("Source Action"))

    keymap.set("n", "]]", vim.diagnostic.goto_next,    desc("Next Diagnostic"))
    keymap.set("n", "[[", vim.diagnostic.goto_prev,    desc("Prev Diagnostic"))
    keymap.set("n", "<A-n>", vim.diagnostic.goto_next, desc("Next Diagnostic (Alt-n)"))
    keymap.set("n", "<A-p>", vim.diagnostic.goto_prev, desc("Prev Diagnostic (Alt-p)"))


    if client and client.server_capabilities.inlayHintProvider then
      keymap.set('n', '<space>h', function()
        local current_setting = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
        vim.lsp.inlay_hint.enable(not current_setting, { bufnr = bufnr })
      end, desc('[lsp] toggle inlay hints'))
    end

    -- Auto-refresh code lenses
    if not client then
      return
    end
    local group = api.nvim_create_augroup(string.format('lsp-%s-%s', bufnr, client.id), {})
    if client.server_capabilities.codeLensProvider then
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost', 'TextChanged' }, {
        group = group,
        callback = function()
          vim.lsp.codelens.refresh { bufnr = bufnr }
        end,
        buffer = bufnr,
      })
      vim.lsp.codelens.refresh { bufnr = bufnr }
    end
  end,
})
