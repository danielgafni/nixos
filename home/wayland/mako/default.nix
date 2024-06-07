{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  services.mako = {
    enable = true;
    font = "Recursive";
    backgroundColor = lib.mkForce "#b31e1e2e"; # add transparency
    defaultTimeout = 10000;
    anchor = "bottom-right";
    height = 250;
    width = 400;
    padding = "5";
    icons = true;
    margin = "10";
    borderRadius = 10;
    borderSize = 3;
    extraConfig = ''
      [category=music-notify]
      default-timeout=5000
    '';
  };
}
