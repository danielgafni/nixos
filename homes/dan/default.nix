# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home-manager/programs

    ./hyprpaper
    ./sops
    ../../packages/nebius-cli.nix
  ];

  programs = {
    nebius-cli.enable = true;
  };

  home = {
    packages = with pkgs; [
      # YubiKey
      yubioath-flutter
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
      pulumi-bin
      argocd
      kind
      inputs.dagger.packages.x86_64-linux.dagger
      devspace

      # wayland/DE
      libnotify # notify-send command
      hyprpaper
      hyprpicker
      grim
      slurp
      wev # show wayland events
      wl-clipboard
      font-manager
      alacritty
      dconf # needed for gtk

      graphviz
      # audio
      pipewire
      wireplumber

      # CLI
      comma
      statix
      ruplacer
      curl
      wget
      eza
      pfetch
      neofetch
      pre-commit
      strace
      just
      sad
      expect
      claude-code

      # messengers
      telegram-desktop
      signal-desktop
      slack
      discord
      zoom
      whatsapp-for-linux
      element-desktop

      # browsers
      google-chrome

      # editors & IDE
      vim
      obsidian

      # jetbrains.gateway

      # Python tools
      pyright
      ruff
      uv

      # development
      graphite-cli
      cargo
      rustc
      yarn
      rustlings
      gcc
      cmake
      rust-analyzer

      # extra
      xarchiver
      #mullvad-vpn
      wireguard-ui
      mpv
      vlc
      bitwarden-desktop
      keepassxc
    ];
  };
}
