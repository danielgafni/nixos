{den, ...}: {
  den.aspects.dan-darwin = {
    includes = [
      den.aspects.dan
      # Darwin shared HM features
      den.aspects.shared-hm-darwin
      den.aspects.raycast
    ];
    homeManager = {
      lib,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.iina];
      home.sessionVariables = {
        NH_FLAKE = "/Users/dan/nixos";
      };
      programs.zsh.initContent = lib.mkOrder 1500 ''
        op account list &>/dev/null 2>&1 || eval "$(op signin)"
      '';
    };
  };
}
