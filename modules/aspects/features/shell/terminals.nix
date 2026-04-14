{den, ...}: {
  den.aspects = {
    terminals = {
      homeManager = {config, ...}: let
        hd = config.my.hostSettings;
      in {
        home.sessionVariables.TERMINAL = "ghostty";

        programs.ghostty = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            confirm-close-surface = false;
            font-family = "Maple Mono NF";
            font-size = hd.font.text.size or 14;
            scrollback-limit = 104857600;
            clipboard-write = "allow";
            background-opacity = 0.9;
            background-blur-radius = 20;
            keybind = [
              "global:cmd+grave_accent=toggle_quick_terminal"
            ];
          };
        };
        programs.kitty = {
          enable = true;
          font = {
            name = "Maple Mono NF";
            size = hd.font.text.size or 14;
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
      };
    };
    terminals-darwin = {
      homeManager = {pkgs, ...}: {
        programs.ghostty.package = pkgs.ghostty-bin;
      };
    };
    terminals-linux = {
      homeManager = {pkgs, ...}: {
        programs.ghostty.package = pkgs.ghostty;
      };
    };
  };
}
