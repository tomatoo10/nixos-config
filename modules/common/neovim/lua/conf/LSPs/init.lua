local old_ft_fallback = require('lze').h.lsp.get_ft_fallback()

require('lze').h.lsp.set_ft_fallback(function(name)
  local lspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. "/lsp/" .. name .. ".lua")
    if not ok then
      ok, cfg = pcall(dofile, lspcfg .. "/lua/lspconfig/configs/" .. name .. ".lua")
    end
    return (ok and cfg or {}).filetypes or {}
  else
    return old_ft_fallback(name)
  end
end)
require('lze').load {
  { import = "conf.LSPs.completion", },
  {
    "nvim-lspconfig",
    for_cat = "general.core",
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

  -- Rustacenvim does not work sadly
  {
    "rust_analyzer",
    for_cat = "langs",
    lsp = {
      on_attach = require('conf.LSPs.on_attach'),
      filetypes = { "rust" },
      settings = {
        ["rust-analyzer"] = {
          cargo = {
                allFeatures = true 
          },
          check = {
                command = "clippy",
          },
          checkOnSave = true,
          diagnostics = {
                  previewRustcOutput = false,
                  useRustcErrorCode = false,
          },
        },
      },
    },
  },

}
