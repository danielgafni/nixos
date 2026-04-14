# Shared home-manager features included by user aspects.
{den, ...}: let
  darwinAspects = [
    den.aspects.gpg-darwin
    den.aspects.cli-darwin
    den.aspects.terminals-darwin
    den.aspects.mac-app-util-hm
  ];
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
  den.aspects = {
    shared-hm = {
      includes = [
        den.aspects.base
        den.aspects.shell
        den.aspects.fonts
        den.aspects.git
        den.aspects.ssh
        den.aspects.terminals
        den.aspects.cli
        den.aspects.nix-tools
      ];
    };
    shared-hm-darwin = {
      includes = darwinAspects;
    };
    shared-hm-linux = {
      includes = linuxAspects;
    };
  };
}
