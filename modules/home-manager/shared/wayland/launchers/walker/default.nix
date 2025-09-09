{pkgs, ...}: {
  home.file = {
    ".config/walker/themes" = {
      source = ./themes;
      recursive = true;
    };
  };

  programs.walker = {
    enable = true;
    runAsService = true;

    # # All options from the config.toml can be used here.
    config = {
      theme = "mocha"; # https://github.com/catppuccin/catppuccin/issues/2849
    };
  };
}
