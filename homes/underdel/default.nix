# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{pkgs, ...}: {
  imports = [
    ../../modules/home-manager/programs/terminals
  ];
  home = {
    packages = with pkgs; [
      # wayland/DE
      libnotify # notify-send command
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
      curl
      wget
      zsh
      eza
      just

      # messengers
      telegram-desktop

      # browsers
      google-chrome
      firefox

      # extra
      xarchiver
      mpv
      vlc
    ];
  };
}
