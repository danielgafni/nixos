# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  stylix,
  ...
}: {
  stylix.cursor = {
    name = "Catppuccin-Mocha-Dark-Cursors";
    size = 32;
    package = pkgs.catppuccin-cursors.mochaDark;
  };

  stylix.fonts.sizes = {
    applications = 20;
    desktop = 20;
    popups = 20;
    terminal = 20;
  };
}
