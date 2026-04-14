_: {
  den.aspects.cli-darwin = {
    homeManager = {pkgs, ...}: {
      programs.rbw.settings.pinentry = pkgs.pinentry_mac;
    };
  };
}
