{
  inputs,
  pkgs,
  config,
  host-settings,
  ...
}: let
  hyprpanelOptions = {
    "bar.customModules.updates.pollingInterval" = 1440000;
    "theme.bar.menus.opacity" = 100;
    "theme.bar.buttons.style" = "wave2";
    "theme.bar.transparent" = true;
    "theme.notification.opacity" = 80;
    "theme.bar.buttons.monochrome" = false;
    "menus.transition" = "crossfade";
    "scalingPriority" = "gdk";
    "theme.font.name" = "Recursive Sans Casual Static Italic";
    "theme.bar.buttons.enableBorders" = true;
    "theme.bar.border.location" = "none";
    "theme.bar.buttons.innerRadiusMultiplier" = "0.4";
    "theme.bar.buttons.radius" = "0.4";
    "bar.launcher.icon" = "❄️";
    "bar.launcher.autoDetectIcon" = false;
    "theme.bar.buttons.dashboard.enableBorder" = false;
    "theme.bar.buttons.workspaces.enableBorder" = false;
    "theme.bar.buttons.workspaces.fontSize" = "1.2em";
    "bar.workspaces.show_icons" = false;
    "bar.workspaces.show_numbered" = false;
    "bar.workspaces.numbered_active_indicator" = "underline";
    "bar.workspaces.showWsIcons" = true;
    "bar.workspaces.showApplicationIcons" = true;
    "bar.workspaces.workspaces" = 5;
    "theme.bar.buttons.windowtitle.enableBorder" = false;
    "menus.media.displayTimeTooltip" = false;
    "menus.media.displayTime" = false;
    "menus.volume.raiseMaximumVolume" = true;
    "menus.clock.weather.location" = "Bucharest";
    # use "Media/avatar.jpg" created by home-manager
    "menus.dashboard.powermenu.avatar.image" = "~/Media/avatar.jpg";
    "menus.clock.time.military" = false;
    "theme.bar.buttons.modules.kbLayout.enableBorder" = false;
    "bar.layouts" = {
      "0" = {
        "left" = ["dashboard" "workspaces" "windowtitle"];
        "middle" = ["media"];
        "right" =
          [
            "volume"
          ]
          ++ [
            "ram"
            "cpu"
            "cputemp"
            "storage"
          ]
          ++ (
            if host-settings.hyprpanel.modules.network
            then ["network"]
            else []
          )
          ++ (
            if host-settings.bluetooth
            then ["bluetooth"]
            else []
          )
          ++ (
            if host-settings.hyprpanel.modules.battery
            then ["battery"]
            else []
          )
          ++ [
            "systray"
            "clock"
            "kbinput"
            "notifications"
          ];
      };
      # TODO: add layouts for more monitors once I have them :)
      #   "1"= {
      #     "left"= ["dashboard" "workspaces" "windowtitle"];
      #     "middle"= ["media"];
      #     "right"= ["volume" "clock" "notifications"];
      #   };
      #   "2"= {
      #     "left"= ["dashboard" "workspaces" "windowtitle"];
      #     "middle"= ["media"];
      #     "right"= ["volume" "clock" "notifications"];

      # };
    };
  };
in {
  home.packages = with pkgs; [
    hyprpanel # awailable via overlay

    # optional deps
    gpustat
    gpu-screen-recorder
    hyprpicker
    hyprsunset
    hypridle
    btop
    matugen
    swww
  ];

  home.file."${config.xdg.cacheHome}/ags/hyprpanel/options.json".text = builtins.toJSON hyprpanelOptions;
}
