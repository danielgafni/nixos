# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
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
    sessionVariables = {
      BROWSER = "google-chrome-stable";

      # the flake is expected to be here
      # this setting is for the `nh` CLI
      FLAKAE = "/home/${user}/nixos";
    };
  };

  catppuccin = {
    enable = true; # sets Catppuccin theme for all programs supported by https://github.com/catppuccin/nix
    flavor = catppuccinFlavor;
    cursors = {
      enable = true;
      accent = cursorAccent; # affects HYPRCURSOR_THEME
    };
    gtk = {
      enable = true; # TODO: remove as it's deprecated
      icon.enable = true;
    };
  };

  # default browser for electron-based apps
  home.sessionVariables.DEFAULT_BROWSER = "google-chrome-stable";

  # Wallpapers
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "image/png" = ["qimgv.desktop"];
        "image/jpeg" = ["qimgv.desktop"];
        "inode/directory" = ["yazi.desktop"];
        "application/pdf" = ["org.pwmt.zathura.desktop"];
        "text/plain" = ["dev.zed.Zed.desktop"];
        "text/uri-list" = ["google-chrome.desktop"];
        "x-scheme-handler/http" = ["google-chrome.desktop"];
        "x-scheme-handler/https" = ["google-chrome.desktop"];
        "text/html" = ["google-chrome.desktop"];
        "x-scheme-handler/about" = ["google-chrome.desktop"];
        "x-scheme-handler/unknown" = ["google-chrome.desktop"];
      };
    };
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
          "org.freedesktop.impl.portal.FileChooser" = "gtk"; # hyprland doesn't provide an implementation of file chooser
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
      useGlobalPkgs = true;
      enable = true;
    };
    dircolors.enable = true;
    btop.enable = true;
    zathura.enable = true;
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

  # TODO: most packages were moved to users/*.nix
  # the common packages should be moved back here
  home.packages = with pkgs; [
    qimgv
  ];
}
