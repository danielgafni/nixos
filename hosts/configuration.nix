# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  allowed-unfree-packages,
  ...
}: {
  imports = [
    ../modules/NixOS/bluetooth
    ../modules/NixOS/yubikey
  ];

  nix = {
    settings = {
      trusted-users = ["root" "dan" "@wheel"];
      substituters = [
        "https://hyprland.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://pre-commit-hooks.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://cosmic.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "danielgafni.cachix.org-1:ZdXJoJEqeiGGOf/MtAiocqj7/vvFbA2MWFVwopJ2WQM="
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      ];
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed-unfree-packages;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager = {
      enable = true;
      settings.main.authPolkit = false;
      # Easiest to use and most distros use this by default.
      insertNameservers = ["1.1.1.1" "8.8.8.8"];
    };

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    proxy.noProxy = "127.0.0.1,localhost";

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.

    # disable firewall (required for WireGuard to work)
    # https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_NetworkManager

    firewall.enable = false;

    firewall.checkReversePath = false;
  };

  # https://github.com/NixOS/nixpkgs/issues/291108
  system.nssDatabases.hosts = lib.mkAfter ["[!UNAVAIL=return]"];

  # stylix
  stylix = {
    image = ./.config/wallpapers/catppuccin-forrest.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    fonts = {
      sansSerif = {
        package = pkgs.cabin;
        name = "Cabin";
      };
      serif = config.stylix.fonts.sansSerif;
      monospace = {
        package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
        name = "FiraCode Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
  };

  services = {
    localtimed.enable = true;
    automatic-timezoned.enable = true;
    desktopManager.cosmic.enable = true;
    #displayManager.cosmic-greeter.enable = true;
    # login screen
    greetd = {
      enable = true;
      settings = {
        initial_session.command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --cmd Hyprland
        '';
      };
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # network printers auto-discovery
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
  };

  location.provider = "geoclue2";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    #font = "FiraCode Nerd Font Mono";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      hyprlock = {};
    };
  };

  environment = {
    pathsToLink = ["/share/zsh"]; # for zsh completions
    sessionVariables = {
      "NIXOS_OZONE_WL" = "1"; # this **must** be a system variable, it can't be defined in user space
    };
    shells = with pkgs; [zsh];
    etc."greetd/environments".text = ''
      Hyprland
    '';
    systemPackages = with pkgs; [
      cachix
      zsh
      starship
      ripgrep
      bat
      eza
      fd
      btop
      zellij
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      neovim
      wget
      curl
      lynx
      lemurs
      brightnessctl
      pavucontrol
      direnv
      (python310.withPackages (ps:
        with ps; [
          pipx
          pre-commit
        ]))
      nix-output-monitor
      minikube
      amazon-ecr-credential-helper
    ];
  };

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  users.extraGroups.docker.members = ["dan"];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;
    users.dan = {
      isNormalUser = true;
      initialPassword = "pw123";
      extraGroups = ["wheel" "docker"]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        home-manager
      ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.zsh.enable = true;

  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; # try this driver)
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090; # or this one

  services.pcscd.enable = true;

  # Screen Sharing
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      # pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  # update nix index for comma every week
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 0 * * 6      dan    nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes' >> /tmp/update-comma-index.log"
    ];
  };
}
