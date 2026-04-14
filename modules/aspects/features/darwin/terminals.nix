_: {
  den.aspects.terminals-darwin = {
    homeManager = {pkgs, ...}: {
      programs.ghostty.package = pkgs.ghostty-bin;
    };
  };
}
