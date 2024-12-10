{pkgs, ...}: {
  home.packages = [pkgs.hyprpaper];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload=~/.config/wallpapers/catppuccin-forrest.png
    wallpaper =,~/.config/wallpapers/catppuccin-forrest.png
  '';

  systemd.user.services.hyprpaper = {
    Unit = {Description = "hyprpaper";};
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["hyprland-session.target"];};
  };
}
