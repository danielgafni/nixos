{den, ...}: {
  den.aspects.satty = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [satty];
      xdg.configFile."satty/config.toml".source = ./satty-config.toml;
    };
  };
}
