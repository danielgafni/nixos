_: {
  # TODO: compile a custom firmware for NuPhy Halo 75 v2
  # with Super + Shift + S disabled in Windows mode
  # and more backlighting options (e.g. https://www.reddit.com/r/NuPhy/comments/1ci4pe3/option_for_reactive_key_press_to_result_in_a/)

  # keyboard support for https://www.usevia.app/
  xdg.configFile."qmk/nuphy-halo75-v2-via.json".source = ./qmk/nuphy-halo75-v2-via.json;

  # Can be applied via https://www.usevia.app/
  xdg.configFile."via/nuphy-halo75-v2-mac-for-linux.json".source = ./VIA/nuphy-halo75-v2-mac-for-linux.json;
}
