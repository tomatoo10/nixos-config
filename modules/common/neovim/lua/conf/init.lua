-- NOTE: Register another one from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger lspconfig setup hooks only on the correct filetypes
require('lze').register_handlers(require('lzextras').lsp)
require("conf.plugins")
require("conf.LSPs")

-- builtin neovim configs
require('conf.opts_and_keys')
