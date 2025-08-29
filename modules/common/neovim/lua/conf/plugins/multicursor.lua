return {
  {
    "multicursor", -- or whatever the actual plugin name is from :NixCats pawsible  
    for_cat = 'general',
    -- Lazy loaded bc of the keys
    keys = {
      -- Add or skip cursor above/below the main cursor
      { "<C-k>", function() require("multicursor-nvim").lineAddCursor(-1) end, mode = {"n", "x"}, desc = "Add cursor above" },
      { "<C-j>", function() require("multicursor-nvim").lineAddCursor(1) end, mode = {"n", "x"}, desc = "Add cursor below" },
      { "<C-S-k>", function() require("multicursor-nvim").lineSkipCursor(-1) end, mode = {"n", "x"}, desc = "Skip cursor above" },
      { "<C-S-j>", function() require("multicursor-nvim").lineSkipCursor(1) end, mode = {"n", "x"}, desc = "Skip cursor below" },

      -- Add or skip adding a new cursor by matching word/selection
      { "<C-n>", function() require("multicursor-nvim").matchAddCursor(1) end, mode = {"n", "x"}, desc = "Add cursor to next match" },
      { "<C-S-n>", function() require("multicursor-nvim").matchSkipCursor(1) end, mode = {"n", "x"}, desc = "Skip match" },
      { "<C-s>", function() require("multicursor-nvim").matchAddCursor(-1) end, mode = {"n", "x"}, desc = "Add cursor to previous match" },
      { "<C-S-s>", function() require("multicursor-nvim").matchSkipCursor(-1) end, mode = {"n", "x"}, desc = "Skip previous match" },

      -- Mouse suppor
      { "<c-leftmouse>", function() require("multicursor-nvim").handleMouse() end, mode = "n", desc = "Add/Remove cursor on click" },
      { "<c-leftdrag>", function() require("multicursor-nvim").handleMouseDrag() end, mode = "n", desc = "Add cursors on drag" },
      { "<c-leftrelease>", function() require("multicursor-nvim").handleMouseRelease() end, mode = "n", desc = "Release mouse" },

      -- Toggle cursors
      { "<c-q>", function() require("multicursor-nvim").toggleCursor() end, mode = {"n", "x"}, desc = "Toggle cursors" },
    },
    after = function(plugin)
      local mc = require("multicursor-nvim")
      mc.setup()

      -- Set up keymap layer for multi-cursor mode
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one
        layerSet({"n", "x"}, "<left>", mc.prevCursor, {desc = "Select previous cursor"})
        layerSet({"n", "x"}, "<right>", mc.nextCursor, {desc = "Select next cursor"})

        -- Delete the main cursor
        layerSet({"n", "x"}, "<leader>x", mc.deleteCursor, {desc = "Delete cursor"})

        -- Enable and clear cursors using escape
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end, {desc = "Clear cursors"})
      end)

      -- Customize how cursors look
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      -- VM compatibility settings
      -- doesn't work, update on insert is not a feature in multicursor-nvim. Maybe it's best to use vim-multi
      vim.g.VM_refresh_in_insert = true
    end,
  },
}
