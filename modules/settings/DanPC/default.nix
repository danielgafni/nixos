let
  darkAfterSeconds = 60 * 5;
  lockAfterSeconds = 60 * 15;
  suspendAfterSeconds = 60 * 30;
in rec {
  hyprlock.monitor = "HDMI-A-2";
  ui.scale = 1.5;
  scaled = x: (builtins.ceil (x * ui.scale));
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
  wayland.hyprlock.auth = [
    "pam:enabled"
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
    size = 32;
  };
  hyprpanel = {
    modules = {
      config = {
        cpuTemperature = {
          sensorPath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon3/temp1_input";
        };
      };
      right = [
        "clock"
        "volume"
        "ram"
        "cpu"
        "storage"
        "cputemp"

        "systray"

        "hypridle"
        "notifications"
        "kbinput"
        "power"
      ];
    };
  };
}
