{pkgs, ...}: {
  home.packages = with pkgs; [
  ];
  programs.nvf.settings.vim.utility.multicursors = {
    enable = true;
  };

  programs.nvf.settings.vim.maps.normal = {
    "<leader>mc" = {
      action = "<cmd>MCstart<cr>";
      desc = "Start Multi-cursor";
    };
    "<C-n>" = {
      action = "<cmd>MCstart<cr>";
      desc = "Select next occurrence";
    };
  };
}
