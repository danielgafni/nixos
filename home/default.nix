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
}: let
  catppuccinFlavor = "mocha";
  cursorAccent = "teal";
in {
  # You can import other home-manager modules here
  imports = [
    ./modules
    # You can also split up your configuration and import pieces of it here:
    ./wayland
    ./services
    ./programs
    ./shell
    ./environment.nix
    ./fonts.nix

    # per-user settings (like packages) are here
    ../users/${user}.nix
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
    username = user;
    homeDirectory = "/home/${user}";
    pointerCursor = {
      # name = "catppuccin-${catppuccinFlavor}-${cursorAccent}-cursors";
      #package = cursorPackage;
      inherit (host-settings.cursor) size;
    };

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "22.11";
  };

  catppuccin = {
    enable = true; # sets Catppuccin theme for all programs supported by https://github.com/catppuccin/nix
    flavor = catppuccinFlavor;
    pointerCursor = {
      enable = true;
      accent = cursorAccent; # affects HYPRCURSOR_THEME
    };
  };

  # Wallpapers
  xdg = {
    enable = true;
    configFile = {
      wallpapers = {
        recursive = true;
        source = ./.config/wallpapers;
      };
      wofi = {
        recursive = true;
        source = ./.config/wofi;
      };
      helix = {
        recursive = true;
        source = ./.config/helix;
      };
    };
    portal = {
      enable = true;
      config = {
        common = {
          default = [
            "hyprland"
            "gtk"
          ];
        };
        hyprland = {
          "org.freedesktop.impl.portal.FileChooser" = "gtk"; # hyprland doesn't provide an implementaion of file chooser
        };
      };

      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  gtk = {
    enable = true;

    catppuccin = {
      enable = true; # TODO: remove as it's deprecated
      icon.enable = true;
    };

    font = {
      name = "Cabin";
      package = pkgs.cabin;
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

  # list of enabled programs with (almost) default configuration
  # if a program requires more configuration, it should be moved to ./programs/...
  programs = {
    home-manager = {
      enable = true;
    };
    dircolors.enable = true;
    btop.enable = true;
  };

  module = {
    flameshot.enable = true; # custom module defined in ./modules/flameshot
  };

  news = {
    display = "silent";
    json = lib.mkForce {};
    entries = lib.mkForce [];
  };

  systemd = {
    # Nicely reload system units when changing configs
    user.startServices = "sd-switch";

    # Using Bluetooth headset buttons to control media player
    user.services.mpris-proxy = {
      Unit.Description = "Mpris proxy";
      Unit.After = ["network.target" "sound.target"];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = ["default.target"];
    };
  };

  # User avatar
  home.file."Media/avatar.jpg" = {
    source = ./assets/avatar.jpg;
  };
}
