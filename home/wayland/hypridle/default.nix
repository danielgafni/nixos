# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  pkgs,
  allowed-unfree-packages,
  config,
  ...
}: let
  darkAfterSeconds = 60 * 5;
  lockAfterSeconds = 60 * 15;
  suspendAfterSeconds = 60 * 30;
in {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = ''pidof hyprlock || hyprlock''; # avoid starting multiple hyprlock instances.
        unlock_cmd = ''notify-send "unlock-cmd"''; # same as above, but unlock
        before_sleep_cmd = ''loginctl lock-session''; # lock before suspend
        after_sleep_cmd = ''hyprctl dispatch dpms on''; # to avoid having to press a key twice to turn on the display.
        ignore_dbus_inhibit = false; # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
        ignore_systemd_inhibit = false; # whether to ignore systemd-inhibit --what=idle inhibitors
      };
      listener = [
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
    };
  };
}
