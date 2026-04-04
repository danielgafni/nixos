{den, ...}: {
  den.aspects.helix = {
    homeManager = {lib, ...}: {
      programs.helix.enable = true;
      xdg.configFile."helix/config.toml".source = lib.mkForce ./helix-config.toml;
    };
  };
}
