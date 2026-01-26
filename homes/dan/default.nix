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
    ./keyboards
    ../../packages/nebius-cli.nix
    ../../packages/waystt.nix
    ../../modules/home-manager/programs/clawdbot
  ];

  programs = {
    nebius-cli.enable = true;
    bun.enable = true;
    waystt = {
      enable = true;
      settings = {
        TRANSCRIPTION_PROVIDER = "openai";
      };
      openaiKeyFile = "/home/dan/.config/sops-nix/secrets/OPENAI_API_KEY";
    };
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
      devenv
      # claude-code

      # messengers
      telegram-desktop
      signal-desktop
      slack
      discord
      zoom
      wasistlos
      element-desktop

      # browsers
      google-chrome

      # editors & IDE
      vim
      obsidian

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
      nodejs

      # extra
      xarchiver
      #mullvad-vpn
      wireguard-ui
      mpv
      vlc
      bitwarden-desktop
      keepassxc

      # AI
      inputs.beads.packages.x86_64-linux.default
    ];
  };
}
