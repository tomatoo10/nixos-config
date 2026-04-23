{pkgs, ...}: {
  home.packages = with pkgs; [
  ];
  programs.nvf.settings.vim.utility.multicursors = {
    enable = true;
  };

  programs.nvf.settings.vim.maps.normal = {
    "<leader>mc" = {
      action = "<cmd>MCstart<cr>";
      desc = "Start Multi-cursor (pattern)";
    };
    "<leader>mv" = {
      action = "<cmd>MCvisual<cr>";
      desc = "Multi-cursor visual";
    };
    "<leader>mp" = {
      action = "<cmd>MCpattern<cr>";
      desc = "Multi-cursor pattern";
    };
  };

  programs.nvf.settings.vim.luaConfigRC.multicursor-keybinds = ''
    -- Sublime-like <C-n>: select word under cursor, then find next occurrence
    vim.keymap.set('n', '<C-n>', function()
      local word = vim.fn.expand('<cword>')
      if word == '' then
        vim.cmd('MCunderCursor')
      else
        vim.cmd('MCstart ' .. vim.fn.escape(word, '/\\'))
      end
    end, { noremap = true, silent = true, desc = "Select word / add cursor (sublime-like)" })

    vim.keymap.set('v', '<C-n>', function()
      vim.cmd('MCvisual')
    end, { noremap = true, silent = true, desc = "Multi-cursor from selection" })
  '';
}
