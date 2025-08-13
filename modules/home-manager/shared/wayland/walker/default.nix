{inputs, ...}: {
  imports = [inputs.walker.homeManagerModules.default];

  programs.walker = {
    enable = true;
    runAsService = true;

    # All options from the config.json can be used here.
    config = {
      search.placeholder = "what now?";
      # ui.fullscreen = true;
      list = {
        height = 200;
      };
      websearch.prefix = "?";
      switcher.prefix = "/";
    };

    # If this is not set the default styling is used.
    theme.style = ''
      * {
        color: #dcd7ba;
      }
    '';
  };
}
