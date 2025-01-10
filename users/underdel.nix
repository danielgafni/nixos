# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  config,
  inputs,
  lib,
  pkgs,
  allowed-unfree-packages,
  host-settings,
  user,
  ...
}: {
  home = {
    packages = with pkgs; [
      # YubiKey
      yubikey-personalization-gui
      yubikey-manager

      # wayland/DE
      libnotify # notify-send command
      wofi
      hyprpaper
      hyprpicker
      grim
      slurp
      wl-clipboard
      font-manager
      dconf # needed for gtk

      # audio
      pipewire
      wireplumber

      # CLI
      comma
      statix
      curl
      wget
      zsh
      starship
      eza
      just
      expect

      # messengers
      telegram-desktop
      slack
      discord
      zoom

      # browsers
      google-chrome
      firefox

      # editors & IDE
      vim
      helix

      # extra
      xarchiver
      mullvad-vpn
      wireguard-ui
      mpv
      vlc
    ];
  };
}
