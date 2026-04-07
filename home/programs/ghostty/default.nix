{
  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    enableFishIntegration = true;
    settings = {
      window-padding-x = 10;
      confirm-close-surface = false;
      window-inherit-working-directory = false;
      window-padding-y = 10;
      clipboard-read = "allow";
      clipboard-write = "allow";
      copy-on-select = "clipboard";
      app-notifications = false;
      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+j=goto_split:down"
        "ctrl+k=goto_split:up"
        "ctrl+l=goto_split:right"
        "ctrl+q=clear_screen"
        "shift+ctrl+h=new_split:left"
        "shift+ctrl+j=new_split:down"
        "shift+ctrl+k=new_split:up"
        "shift+ctrl+l=new_split:right"
        "shift+ctrl+tab=new_tab"
      ];
    };
  };
}
