{
  default,
  config,
  ...
}: let
  inherit (default) xcolors;
  # inherit (default) config;
in {
  programs.kitty = {
    enable = true;
    font = {
      name = default.terminal.font;
    };
    theme = "Catppuccin-Mocha";
    settings = {
      scrollback_lines = 10000;
      placement_strategy = "center";

      allow_remote_control = "yes";
      enable_audio_bell = "no";

      # idk who even could have the thought cancer like this should exist
      #visual_bell_duration = "0.1";
      #visual_bell_color = xcolors.rosewater;

      copy_on_select = "clipboard";

      selection_foreground = "none";
      selection_background = "none";

      background_opacity = toString default.terminal.opacity;
    };
  };
}
