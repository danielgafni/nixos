{pkgs, ...}: {
  home.packages = with pkgs; [
    zed-editor
  ];

  xdg.configFile."zed/settings.json" = {
    source = ./settings.json;
  };
}
