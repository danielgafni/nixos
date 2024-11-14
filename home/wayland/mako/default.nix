{
  inputs,
  pkgs,
  config,
  lib,
  host-settings,
  ...
}: let
  # mako accepts configuration in pixels, so we need to scale it for specific monitors
  # according to "scale" parameter in host-settings
  scaled = x: (builtins.ceil (x * host-settings.ui.scale));
in {
  services.mako = {
    enable = true;
    font = "Recursive ${toString host-settings.font.text.size}";
    backgroundColor = lib.mkForce "#1e1e2e80"; # add transparency
    defaultTimeout = 10000;
    anchor = "bottom-right";
    height = scaled 150;
    width = scaled 350;
    padding = toString (scaled 3);
    icons = true;
    margin = "${toString (scaled 6)},${toString (scaled 3)},${toString (scaled 6)}"; # aligh with hyprland windows spacing
    borderRadius = scaled 10;
    borderSize = scaled 2;
    extraConfig = ''
      [category=music-notify]
      default-timeout=5000

      [mode=do-not-disturb]
      invisible=1
    '';
  };
}
