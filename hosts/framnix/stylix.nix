{
  config,
  lib,
  pkgs,
  stylix,
  ...
}: {
  stylix.cursor = {
    name = "Catppuccin-Mocha-Dark-Cursors";
    size = 16;
    package = pkgs.catppuccin-cursors.mochaDark;
  };

  stylix.fonts.sizes = {
    applications = 12;
    desktop = 12;
    popups = 12;
    terminal = 12;
  };
}
