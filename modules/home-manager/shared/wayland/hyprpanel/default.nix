{
  pkgs,
  config,
  host-settings,
  ...
}: {
  programs.hyprpanel = {
    enable = true;
    settings = {
      bar = {
        layouts = {
          # See 'https://hyprpanel.com/configuration/panel.html'.
          "0" = {
            "left" = ["dashboard" "workspaces" "windowtitle"];
            "middle" = ["media"];
            "right" = host-settings.hyprpanel.modules.right;
          };
        };

        customModules = {
          updates.pollingInterval = 1440000;
          cpuTemp.sensor = host-settings.hyprpanel.modules.config.cpuTemperature.sensorPath;
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

        dashboard.powermenu.avatar.image = toString config.home.file."Media/avatar.jpg".source;
      };

      scalingPriority = "gdk";

      theme = {
        font = {
          name = "Recursive Sans Casual Static Italic";
          size = toString host-settings.font.text.size;
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

  home.packages = with pkgs; [
    # optional deps
    gpustat
    gpu-screen-recorder
    hyprpicker
    hyprsunset
    hypridle
    btop
    matugen
    swww
    grimblast
  ];
}
