{pkgs, ...}: {
  home.packages = with pkgs; [
    satty
  ];
  xdg.configFile.".satty/config.toml".source = ./config.toml;
}
