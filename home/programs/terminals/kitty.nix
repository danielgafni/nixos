{host-settings, ...}: {
  programs.kitty = {
    enable = true;
    catppuccin.enable = true;
    font = {
      name = "Fira Code Nerd Font";
      inherit (host-settings.font.text) size;
    };
    settings = {
      scrollback_lines = 10000;
      placement_strategy = "center";

      allow_remote_control = "yes";
      enable_audio_bell = "no";

      copy_on_select = "clipboard";

      selection_foreground = "none";
      selection_background = "none";

      background_opacity = "0.9";
    };
  };
}
