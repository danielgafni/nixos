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
  nix.settings = {
    netrc-file = /etc/nix/.netrc; # for credentials (like pribate PyPI server)
    substituters = [
      "https://hyprland.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "danielgafni.cachix.org-1:ZdXJoJEqeiGGOf/MtAiocqj7/vvFbA2MWFVwopJ2WQM="
    ];
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed-unfree-packages;
  };

  nix.settings.trusted-users = ["root" "dan"];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = lib.mkDefault true;
  # networking.nameservers = ["1.1.1.1" "1.0.0.1" "8.8.8.8" "8.8.4.4" "9.9.9.9"];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;
    settings.main.authPolkit = false;
  }; # Easiest to use and most distros use this by default.

  networking.networkmanager.insertNameservers = ["1.1.1.1" "8.8.8.8"];

  # https://github.com/NixOS/nixpkgs/issues/291108
  system.nssDatabases.hosts = lib.mkAfter ["[!UNAVAIL=return]"];

  # disable firewall (required for WireGuard to work)
  # https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_NetworkManager
  networking.firewall.checkReversePath = false;

  # stylix
  stylix.image = ./.config/wallpapers/catppuccin-forrest.png;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  stylix.fonts = {
    monospace = {
      package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
      name = "Fira Code Nerd Font";
    };
    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };

  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Belgrade";
  services.localtimed.enable = true;
  services.automatic-timezoned.enable = true;
  location.provider = "geoclue2";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  networking.proxy.noProxy = "127.0.0.1,localhost";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "FiraCode Nerd Font";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # login screen
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd Hyprland
      '';
    };
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # network printers auto-discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # Enable sound.
  #sound.enable = true;
  #hardware.pulseaudio = {
  #  enable = true;
  #  package = pkgs.pulseaudioFull;  # extra codecs
  #};

  # Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  security.pam.services.hyprlock = {};

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  # Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    features = {
      buildkit = true;
    };
  };

  users.extraGroups.docker.members = ["dan"];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dan = {
    isNormalUser = true;
    initialPassword = "pw123";
    extraGroups = ["wheel" "docker"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      home-manager
    ];
  };

  # Slack native Wayland support
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cachix
    zsh
    starship
    ripgrep
    bat
    eza
    fd
    btop
    zellij
    helix
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

  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };
  };

  #programs.ags = {
  #  enable = true;
  #  configDir = "../home/.config/ags";
  #};

  # programs = {
  #   direnv.enable = true;
  #   nix-direnv.enable = true;
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;
  # programs.helix.enable = true;
  # programs.helix.defaultEditor = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; # try this driver)
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090; # or this one

  #services.xserver.enable = true;
  #services.xserver.displayManager.sddm.enable = true;

  security.polkit.enable = true;

  # YubiKey
  services.udev.packages = [pkgs.yubikey-personalization];
  services.yubikey-agent.enable = false;
  programs.ssh.startAgent = false; # using gpg agent instead

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

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

  # Lorri - direnv integration for Nix
  services.lorri.enable = true;

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  # Custom /etc files

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
      bluez_monitor.properties = {
      	["bluez5.enable-sbc-xq"] = true,
      	["bluez5.enable-msbc"] = true,
      	["bluez5.enable-hw-volume"] = true,
      	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '')
  ];

  # update nix index for comma every week
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 0 * * 6      dan    nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes' >> /tmp/update-comma-index.log"
    ];
  };

  #environment.etc."lemurs.wayland.Hyprland" = {
  #  text = ''
  #    #! /bin/sh
  #    exec Hyprland
  #    '';
  #  mode = "0755";
  #};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}
