_: {
  den.aspects.cli-linux = {
    homeManager = {pkgs, ...}: {
      programs.rbw.settings.pinentry = pkgs.pinentry-gtk2;
    };
  };
}
