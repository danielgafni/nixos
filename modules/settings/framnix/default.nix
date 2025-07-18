let
  darkAfterSeconds = 60 * 5;
  lockAfterSeconds = 60 * 15;
  suspendAfterSeconds = 60 * 30;
in rec {
  hyprlock.monitor = "eDP-1";
  ui.scale = 1.6;
  scaled = x: (builtins.ceil (x * ui.scale));
  wayland.hyprland.monitor = [
    ",preferred,auto,${toString ui.scale}"
  ];
  wayland.hyprlock.auth = [
    "pam:enabled"
    "fingerprint:enabled"
  ];
  wayland.hypridle.listener = [
    {
      timeout = darkAfterSeconds;
      on-timeout = ''brightnessctl -s set 15%''; # set monitor backlight to minimum, avoid 0 on OLED monitor.
      on-resume = ''brightnessctl -r''; # monitor backlight restore.
    }
    {
      timeout = darkAfterSeconds;
      on-timeout = ''brightnessctl -sd platform::kbd_backlight set 0''; # turn off keyboard backlight.
      on-resume = ''brightnessctl -rd platform::kbd_backlight''; # turn on keyboard backlight.
    }
    {
      timeout = lockAfterSeconds;
      on-timeout = ''loginctl lock-session''; # lock screen when timeout has passed
    }
    {
      timeout = lockAfterSeconds + 30;
      on-timeout = ''hyprctl dispatch dpms off''; # screen off when timeout has passed
      on-resume = ''hyprctl dispatch dpms on''; # screen on when activity is detected after timeout has fired.
    }
    {
      timeout = suspendAfterSeconds;
      on-timeout = ''systemctl suspend''; # suspend pc
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
  hyprpanel = {
    settings = {
    };
    modules = {
      config = {
        cpuTemperature = {
          sensorPath = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
        };
      };
      right = [
        "clock"
        "volume"
        "network"
        "bluetooth"

        "cputemp"

        "systray"

        "hypridle"
        "notifications"
        "battery"
        "kbinput"
        "power"
      ];
    };
  };
}
