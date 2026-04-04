{den, ...}: {
  den.aspects.hyprlock = {
    homeManager = {
      config,
      lib,
      ...
    }: let
      hd = config.my.hostSettings;
      inherit (config.catppuccin) sources;
    in {
      catppuccin.hyprlock = {
        useDefaultConfig = false;
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          auth = hd.wayland.hyprlock.auth or ["pam:enabled"];
          "$font" = "Recursive";
          general = {
            disable_loading_bar = false;
            hide_cursor = false;
          };
          background = {
            monitor = "";
            path = "screenshot";
            blur_passes = 2;
            blur_size = 7;
            color = "$base";
          };
          label = [
            {
              monitor = "";
              text = ''cmd[update:30000] echo "$(date +"%R")"'';
              color = "$text";
              font_size = 90;
              font_family = "$font";
              position = "-130, -100";
              halign = "right";
              valign = "top";
              shadow_passes = 2;
            }
            {
              monitor = "";
              text = ''cmd[update:43200000] echo "$(date +"%A, %d %B %Y")"'';
              color = "$text";
              font_size = 25;
              font_family = "$font";
              position = "-130, -250";
              halign = "right";
              valign = "top";
              shadow_passes = 2;
            }
            {
              monitor = "";
              text = "$LAYOUT";
              color = "$text";
              font_size = 20;
              font_family = "$font";
              rotate = 0;
              position = "-130, -310";
              halign = "right";
              valign = "top";
              shadow_passes = 2;
            }
          ];
          input-field = [
            {
              monitor = "";
              size = "400, 70";
              outline_thickness = 4;
              dots_size = 0.2;
              dots_spacing = 0.2;
              dots_center = true;
              outer_color = "$accent";
              inner_color = "$surface0";
              font_color = "$text";
              fade_on_empty = false;
              placeholder_text = ''<span foreground="##$textAlpha"><i>󰌾  Logged in as </i><span foreground="##$accentAlpha">$USER</span></span>'';
              hide_input = false;
              check_color = "$accent";
              fail_color = "$red";
              fail_text = ''<i>$FAIL <b>($ATTEMPTS)</b></i>'';
              capslock_color = "$yellow";
              position = "0, -185";
              halign = "center";
              valign = "center";
              shadow_passes = 2;
            }
          ];
        };
      };
    };
  };
}
