# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  pkgs,
  allowed-unfree-packages,
  ...
}: {
  programs.hyprlock = {
    enable = true;
  };
}
