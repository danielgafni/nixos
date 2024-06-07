{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  services.mako = {
    enable = true;
    font = "Recursive 10";
    backgroundColor = lib.mkForce "#1e1e2e80"; # b3 # add transparency
    defaultTimeout = 10000;
    anchor = "bottom-right";
    height = 150;
    width = 350;
    padding = "3";
    icons = true;
    margin = "6,3,6"; # aligh with hyprland windows spacing
    borderRadius = 10;
    borderSize = 2;
    extraConfig = ''
      [category=music-notify]
      default-timeout=5000
    '';
  };
}
