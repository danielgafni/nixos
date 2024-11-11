{host-settings, ...}: {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      return {
        font = wezterm.font("FiraCode Nerd Font Mono"),
        font_size = ${toString host-settings.font.text.size},
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };
}
