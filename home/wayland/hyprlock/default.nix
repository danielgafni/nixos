{
  inputs,
  lib,
  pkgs,
  allowed-unfree-packages,
  config,
  user,
  ...
}: let
  # TODO: probably these is a cleaner way to get access to these variables?
  inherit (config.catppuccin) sources;
  cfg = config.wayland.windowManager.hyprland.catppuccin;
in {
  # tmp workaround for https://github.com/catppuccin/nix/issues/205
  # just enable programs.swaylock for now
  programs.swaylock.enable = true;

  # important! security.pam.services.hyprlock = {}; has to be added to NixOS config
  programs.hyprlock = {
    enable = true;
    settings = {
      source = [
        "${sources.hyprland}/themes/${cfg.flavor}.conf"
        (builtins.toFile "hyprland-${cfg.accent}-accent.conf" ''
          $accent=''$${cfg.accent}
          $accentAlpha=''$${cfg.accent}Alpha
        '')
      ];
      "$font" = "Recursive";
      general = {
        disable_loading_bar = false;
        hide_cursor = false;
      };
      background = {
        monitor = "";
        path = "/tmp/screenshot.png";
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
          rotate = 0; # degrees, counter-clockwise
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
      # image = [
      #   {
      #     monitor = "";
      #     path = "/home/${user}/Media/avatar.jpg"; # avatar set in home/default.nix
      #     size = 350;
      #     border_color = "$accent";
      #     rounding = -1;
      #     position = "0, 75";
      #     halign = "center";
      #     valign = "center";
      #     shadow_passes = 2;
      #   }
      # ];
    };
  };
}
