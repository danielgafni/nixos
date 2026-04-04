{den, ...}: let
  linuxAspects = [
    den.aspects.desktop-linux
    den.aspects.services-linux
    den.aspects.hyprland
    den.aspects.hyprpanel
    den.aspects.hyprlock
    den.aspects.hypridle
    den.aspects.satty
    den.aspects.vicinae
    den.aspects.ags
    den.aspects.cli-linux
    den.aspects.terminals-linux
    den.aspects.base-linux
    den.aspects.nix-tools-linux
    den.aspects.shell-linux
  ];
in {
  den.aspects.shared-hm-linux = {
    includes = linuxAspects;
  };
}
