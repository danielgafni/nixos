{host-settings, ...}: {
  programs.wezterm = {
    enable = false; # cause performance issues in zsh (wtf?)
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
