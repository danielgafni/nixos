{pkgs, ...}: {
  # TODO: switch to home-manager
  home.packages = with pkgs; [
    helix
  ];

  xdg = {
    enable = true;
    configFile = {
      ".config/helix/config.toml" = {
        source = ./config.toml;
      };
    };
  };
}
