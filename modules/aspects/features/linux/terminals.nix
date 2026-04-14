_: {
  den.aspects.terminals-linux = {
    homeManager = {pkgs, ...}: {
      programs.ghostty.package = pkgs.ghostty;
    };
  };
}
