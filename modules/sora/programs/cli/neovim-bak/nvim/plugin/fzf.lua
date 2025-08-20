-- Keymaps
local fzf = require('fzf-lua')

vim.keymap.set('n', 'ff', fzf.files, { desc = '[f]ind [f]iles' })
vim.keymap.set('n', 'fr', fzf.oldfiles, { desc = '[f]ind [r]ecent' })
vim.keymap.set('n', 'fw', fzf.live_grep, { desc = '[f]ind [w]ord' })
vim.keymap.set('n', '<C-g>', fzf.grep_cword, { desc = '[f]ind current word' })
vim.keymap.set('n', 'fc', fzf.command_history, { desc = '[f]ind [c]ommand' })

-- Buffers
vim.keymap.set('n', 'fb', fzf.buffers, { desc = '[f]ind [b]uffer' })

-- LSP
-- Note the capital 'S' for document Symbols
vim.keymap.set('n', 'fS', fzf.lsp_document_symbols, { desc = '[f]ind document [S]ymbols' })
vim.keymap.set('n', 'fs', fzf.lsp_workspace_symbols, { desc = '[f]ind workspace [s]ymbols' })

fzf.setup({'fzf-native'})
