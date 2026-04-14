{den, ...}: {
  den.aspects.content = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.qbittorrent];
      xdg.configFile."qbittorrent/catppuccin-mocha.qbtheme".source = ./data/catppuccin-mocha.qbtheme;
    };
  };
}
