{pkgs, ...}: {
  home.packages = [
    pkgs.qbittorrent
  ];
  xdg.configFile."qbittorrent/catppuccin-mocha.qbtheme".source = ./catppuccin-mocha.qbtheme;
}
