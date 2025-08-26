require('lze').load {
  {
    "conform.nvim",
    for_cat = 'format',
    keys = {
      { "<leader>=", desc = "Format File" },
    },
    -- colorscheme = "",
    after = function (plugin)
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          rust = { "rustfmt", lsp_format = "fallback"},
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>=", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[F]ormat [F]ile" })
    end,
  },
}
