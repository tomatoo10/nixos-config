{
  programs.mangohud = {
    enable = true;
    # Sets MANGOHUD=1 in the session, enabling the overlay for all Vulkan/OpenGL
    # applications. Proton (Steam's compatibility layer) also reads this variable
    # and activates MangoHUD inside the container automatically.
    enableSessionWide = true;
    settings = {
      # Start hidden; toggle on/off with Shift_R+F12
      no_display = true;
    };
  };
}
