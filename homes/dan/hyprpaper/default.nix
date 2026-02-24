_: {
  xdg = {
    enable = true;
    configFile = {
      wallpapers = {
        recursive = true;
        source = ../wallpapers;
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = {
        monitor = "";
        path = "~/.config/wallpapers/catppuccin-forest.png";
      };
    };
  };
}
