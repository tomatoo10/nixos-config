return {
  {
    "fzf-lua",
    for_cat = 'general',
    cmd = {"FzfLua"},
    -- Telescope/fzf-lua keybinds
    keys = {
      { "ff", function() require('fzf-lua').files() end, mode = {"n"}, desc = '[F]ind [F]iles' },
      { "fw", function() require('fzf-lua').live_grep() end, mode = {"n"}, desc = '[F]ind [W]ord (Grep)' },
      { "fg", function() require('fzf-lua').grep({ search = vim.fn.expand("<cword>") }) end, mode = {"n"}, desc = '[F]ind [G]rep on Current Word' },
      { "fr", function() require('fzf-lua').oldfiles() end, mode = {"n"}, desc = '[F]ind [R]ecent Files' },
      { "fk", function() require('fzf-lua').keymaps() end, mode = {"n"}, desc = '[F]ind [K]eymaps' },
      { "fh", function() require('fzf-lua').help_tags() end, mode = {"n"}, desc = '[F]ind [H]elp Tags' },
      { "fM", '<cmd>lua require("fzf-lua").notify()<CR>', mode = {"n"}, desc = '[F]ind [M]essages' },
      { "fb", function() require('fzf-lua').buffers() end, mode = {"n"}, desc = '[F]ind [B]uffers' },
      { "fr", function() require('fzf-lua').resume() end, mode = {"n"}, desc = '[F]ind [R]esume' },
      { "fs", function() require('fzf-lua').builtin() end, mode = {"n"}, desc = '[F]ind [S]elect Builtin' },
      { "fd", function() require('fzf-lua').diagnostics() end, mode = {"n"}, desc = '[F]ind [D]iagnostics' },
      { "fW", function() require('fzf-lua').grep({ grep_open_files = true, prompt = 'Live Grep in Open Files' }) end, mode = {"n"}, desc = '[F]ind in Open Files' },
    },

    load = function(name)
      vim.cmd.packadd(name)
    end,
    after = function()
      require('fzf-lua').setup({
        winopts = { preview = { vertical = "down:50%" } },
        keymap = { builtin = { ["<c-enter>"] = "toggle-all" } },
        fzf_bin = "fzf",
      })
    end,
  },
}

