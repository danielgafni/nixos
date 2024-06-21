# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  config,
  inputs,
  lib,
  pkgs,
  allowed-unfree-packages,
  host-settings,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ./wayland
    ./programs
    ./shell
    ./eww.nix
    ./hyprpaper.nix
    ./environment.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];

  nixpkgs = {
    overlays = [
      inputs.nixpkgs-wayland.overlay
    ];
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed-unfree-packages;
    };
  };

  home = {
    username = "dan";
    homeDirectory = "/home/dan";
  };

  home.pointerCursor = {
    size = host-settings.cursor.size;
  };

  catppuccin.enable = true; # sets Catppuccin theme for all programs supported by https://github.com/catppuccin/nix
  catppuccin.flavor = "mocha";
  xdg.enable = true;

  programs.dircolors.enable = true;

  # Cursor
  home.pointerCursor = {
    name = "Catppuccin-Mocha-Dark-Cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    gtk.enable = true;
    # size is defined in hosts//home.nix
  };

  # home-manager.backupFileExtension = ".bak";

  gtk = {
    enable = true;
    font = {
      name = "Cabin";
      package = pkgs.cabin;
    };

    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = host-settings.cursor.size;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  home.packages = with pkgs; [
    # YubiKey
    yubikey-personalization-gui
    yubikey-manager

    # devops
    kubectl
    kubeseal
    lens
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
    flameshot
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
    noto-fonts-cjk
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

    jetbrains.gateway

    # Python tools
    poetry
    pyright
    mypy
    black
    ruff
    isort

    # extra
    xarchiver
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # list of enabled programs with (almost) default configuration
  # if a program requires more configuration, it should be moved to ./programs/...
  programs.btop.enable = true;

  news.display = "silent";
  news.json = lib.mkForce {};
  news.entries = lib.mkForce [];

  # random stuff

  # Wallpapers
  xdg.configFile."wallpapers" = {
    recursive = true;
    source = ./.config/wallpapers;
  };

  # wofi (app launcher)
  xdg.configFile."wofi" = {
    recursive = true;
    source = ./.config/wofi;
  };

  xdg.configFile."helix" = {
    recursive = true;
    source = ./.config/helix;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Using Bluetooth headset buttons to control media player
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = ["network.target" "sound.target"];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = ["default.target"];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
