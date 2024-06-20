let
  darkAfterSeconds = 60 * 5;
  lockAfterSeconds = 60 * 15;
  suspendAfterSeconds = 60 * 30;
in rec {
  ui.scale = 1.6;
  wayland.hyprland.monitor = [
    ",preferred,auto,${toString ui.scale}"
    # workaround for https://github.com/hyprwm/Hyprland/issues/6309
    "Unknown-1,disable"
  ];
  wayland.hypridle.listener = [
    {
      timeout = darkAfterSeconds;
      on-timeout = ''brightnessctl -s set 15%''; # set monitor backlight to minimum, avoid 0 on OLED monitor.
      on-resume = ''brightnessctl -r''; # monitor backlight restore.
    }
    {
      timeout = lockAfterSeconds;
      on-timeout = ''loginctl lock-session''; # lock screen when timeout has passed
    }
  ];
  font = {
    titles = {
      size = 14;
    };
    text = {
      size = 12;
    };
  };
  cursor = {
    size = 12;
  };
}
