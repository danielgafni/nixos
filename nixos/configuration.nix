# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings = {
    netrc-file = /etc/nix/.netrc; # for credentials (like pribate PyPI server)
    substituters = [
      "https://hyprland.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
    ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framnix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;
    extraConfig = ''
      [main]
      auth-polkit=false
    '';
  }; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

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

  # moved to home-manager
  # fonts.packages = with pkgs; [

  # ];

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

  # Enable sound.
  #sound.enable = true;
  #hardware.pulseaudio = {
  #  enable = true;
  #  package = pkgs.pulseaudioFull;  # extra codecs 
  #};

  # Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations

  # rtkit is optional but recommended
  security.rtkit.enable = true;
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
  environment.shells = with pkgs; [ zsh ];

  # Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    features = {
      buildkit = true;
    };
  };

  users.extraGroups.docker.members = [ "dan" ];


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dan = {
    isNormalUser = true;
    initialPassword = "pw123";
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs;
      [
        home-manager
      ];
  };

  # Slack native Wayland support
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    zsh
    starship
    ripgrep
    bat
    exa
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
    (python310.withPackages (ps: with ps; [
      pipx
      pre-commit
    ]))
  ];

  nixpkgs.config = {

    allowUnfree = true;

    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };

  };

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
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;

  #services.xserver.enable = true;
  #services.xserver.displayManager.sddm.enable = true;

  security.polkit.enable = true;

  # YubiKey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  # Screen Sharing
  xdg = {
    portal = {
      enable = true;
      # gtkUsePortal = true;  # reprecated
    };
  };

  # Lorri - direnv integration for Nix
  services.lorri.enable = true;

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  # Custom /etc files

  environment.etc."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
    		bluez_monitor.properties = {
    			["bluez5.enable-sbc-xq"] = true,
    			["bluez5.enable-msbc"] = true,
    			["bluez5.enable-hw-volume"] = true,
    			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
    		}
    	'';

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
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

