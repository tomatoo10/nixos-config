-- Lazy-loading LSP based on file types using lsp-config, if not found it uses ft defined in the plugin spec.
local old_ft_fallback = require('lze').h.lsp.get_ft_fallback()
require('lze').h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" })
      or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
  if not lspcfg then
    return old_ft_fallback(name)
  end
  local cfg = dofile(lspcfg .. "/lsp/" .. name .. ".lua")
      or dofile(lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
  return (cfg and cfg.filetypes) or {}
end)

-- TODO: Am i even using lspconfig here? Can i put rustacenvim to work?
require('lze').load {
  { import = "conf.LSPs.completion" },

  {
    "nvim-lspconfig",
    for_cat = "general",
    on_require = { "lspconfig" },
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = require('conf.LSPs.on_attach'),
      })
    end,
  },

  -- {
  --   "rust_analyzer",
  --   -- This will make it be loaded by lsp-config
  --   lsp = {
  --     on_attach = require('conf.LSPs.on_attach'),
  --     filetypes = { "rust" },
  --     settings = {
  --       ["rust-analyzer"] = {
  --         cargo = {
  --               allFeatures = true
  --         },
  --         check = {
  --               command = "clippy",
  --         },
  --         checkOnSave = true,
  --         diagnostics = {
  --                 previewRustcOutput = false,
  --                 useRustcErrorCode = false,
  --         },
  --       },
  --     },
  --   },
  -- },

  {
    "rustaceanvim",
    for_cat = "general",
    after = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = require('conf.LSPs.on_attach')
        }
      }
    end,
  },

  -- Lua LSP
  {
    "lua_ls",
    lsp = {
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          diagnostics = {
            -- The fuck is this for
            globals = { "nvim", "neovim", "nixCats", "vim" },
            disable = { 'missing-fields' },
          },
          telemetry = { enabled = false },
        },
      },
    },
  },

  -- Nix
  {
    "nil_ls",
    lsp = {
      filetypes = { "nix" },
    },
  },
}
