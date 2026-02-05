{host-settings, ...}: {
  programs.kitty = {
    enable = true;
    font = {
      name = "Maple Mono NF";
      inherit (host-settings.font.text) size;
    };
    settings = {
      scrollback_lines = 10000;
      placement_strategy = "center";

      allow_remote_control = "yes";
      enable_audio_bell = "no";
      confirm_os_window_close = "-1";

      copy_on_select = "clipboard";

      selection_foreground = "none";
      selection_background = "none";

      background_opacity = "0.9";
    };
  };
}
