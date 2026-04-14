_: {
  den.aspects.content-linux = {
    homeManager = {pkgs, ...}: {
      programs.obs-studio = {
        enable = true;
        plugins = [pkgs.obs-studio-plugins.wlrobs];
      };
    };
  };
}
