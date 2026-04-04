{den, ...}: let
  darwinAspects = [
    den.aspects.gpg-darwin
    den.aspects.cli-darwin
    den.aspects.terminals-darwin
    den.aspects.mac-app-util-hm
  ];
in {
  den.aspects.shared-hm-darwin = {
    includes = darwinAspects;
  };
}
