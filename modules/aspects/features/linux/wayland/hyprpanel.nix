{den, ...}: {
  den.aspects.hyprpanel = {
    homeManager = {
      config,
      pkgs,
      ...
    }: let
      hd = config.my.hostSettings;
      hyprpanel = hd.hyprpanel or {};
      text = hd.font.text or {size = 12;};
    in {
      programs.hyprpanel = {
        enable = true;
        # systemd.enable defaults to true — starts hyprpanel via graphical-session.target
        settings = {
          bar = {
            layouts = {
              # See 'https://hyprpanel.com/configuration/panel.html'.
              "0" = {
                left = ["dashboard" "workspaces" "windowtitle"];
                middle = ["media"];
                right = hyprpanel.modules.right or [];
              };
            };

            customModules = {
              updates.pollingInterval = 1440000;
              cpuTemp.sensor = hyprpanel.modules.config.cpuTemperature.sensorPath or "";
            };

            launcher = {
              icon = "❄️";
              autoDetectIcon = false;
            };

            workspaces = {
              show_icons = false;
              show_numbered = false;
              numbered_active_indicator = "underline";
              showWsIcons = true;
              showApplicationIcons = true;
              workspaces = 5;
            };
          };

          menus = {
            transition = "crossfade";

            media = {
              displayTimeTooltip = false;
              displayTime = false;
            };

            volume.raiseMaximumVolume = true;

            clock = {
              weather.location = "Bucharest";
              time.military = false;
            };
          };

          scalingPriority = "gdk";

          theme = {
            font = {
              name = "Recursive Sans Casual Static Italic";
              size = "${toString (text.size or 12)}px";
            };

            notification.opacity = 80;

            bar = {
              menus.opacity = 100;
              transparent = true;
              border.location = "none";

              buttons = {
                style = "wave2";
                monochrome = false;
                enableBorders = true;
                innerRadiusMultiplier = "0.4";
                radius = "0.4";

                dashboard.enableBorder = false;
                workspaces.enableBorder = false;
                windowtitle.enableBorder = false;
                modules.kbLayout.enableBorder = false;
              };
            };
          };
        };
      };

      # Optional hyprpanel deps
      home.packages = with pkgs; [
        gpustat
        gpu-screen-recorder
        hyprpicker
        hyprsunset
        btop
        matugen
        swww
        grimblast
      ];
    };
  };
}
