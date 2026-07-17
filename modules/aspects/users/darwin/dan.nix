{den, ...}: {
  den.aspects.dan-darwin = {
    includes = [
      den.aspects.dan
      # Darwin shared HM features
      den.aspects.shared-hm-darwin
      den.aspects.raycast
      # Window manager + borders (dan-only)
      den.aspects.aerospace
      den.aspects.jankyborders
      den.aspects.commandshift
      # den.aspects.swiftbar  # disabled — AeroSpace has a native menubar indicator
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
      xdg.configFile."herdr/config.toml".source = ./herdr.toml;
      xdg.configFile."herdr/plugins/config/persiyanov.reviewr/config.toml".source = ./herdr-reviewr.toml;
      programs = {
        zsh.initContent = lib.mkOrder 1500 ''
          op account list &>/dev/null 2>&1 || eval "$(op signin)"
        '';
        ssh.includes = ["~/.ssh/puffy/*"];
      };
    };
  };
}
