-- NOTE: builtin neovim configs
require('conf.opts_and_keys')

-- NOTE: Register another one from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger lspconfig setup hooks only on the correct filetypes
require('lze').register_handlers(require('lzextras').lsp)

-- NOTE: general plugins
require("conf.plugins")

-- NOTE: LSP plugins 
require("conf.LSPs")
