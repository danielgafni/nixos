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

      # devops
      kubectl
      kubeseal
      #lens
      sops
      age
      (pkgs.wrapHelm pkgs.kubernetes-helm {plugins = [];})
      awscli2
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      opentofu
      terragrunt
      argocd
      kind

      # wayland/DE
      libnotify # notify-send command
      wofi
      hyprpaper
      hyprpicker
      grim
      slurp
      wev # show wayland events
      wl-clipboard
      font-manager
      alacritty
      kitty
      dconf # needed for gtk

      graphviz
      # audio
      pipewire
      wireplumber

      # CLI
      comma
      statix
      git
      delta
      curl
      wget
      zsh
      starship
      eza
      pfetch
      neofetch
      pre-commit
      strace
      just
      sad
      expect

      # TUI
      ranger

      # fonts
      (
        nerdfonts.override {
          fonts = [
            "FiraCode"
            "DroidSansMono"
          ];
        }
      )
      recursive # for eww
      fira-code
      fira-code-symbols
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      cabin

      # messengers
      telegram-desktop
      signal-desktop
      slack
      discord
      zoom

      # browsers
      google-chrome
      firefox
      lynx

      # editors & IDE
      vim
      helix
      obsidian

      jetbrains.gateway

      # Python tools
      poetry
      pyright
      mypy
      black
      ruff
      isort
      uv

      # development
      graphite-cli

      # extra
      xarchiver
      mullvad-vpn
      wireguard-ui
      mpv
      vlc
    ];
  };
}
