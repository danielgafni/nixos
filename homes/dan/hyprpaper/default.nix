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

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload=~/.config/wallpapers/catppuccin-forest.png
    wallpaper =,~/.config/wallpapers/catppuccin-forest.png
  '';
}
