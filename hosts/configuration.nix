# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  users,
  inputs,
  ...
}: {
  inherit users;

  imports = [
    ../modules/NixOS/yubikey
    ../modules/NixOS/1password
  ];

  nix = {
    settings = {
      trusted-users = ["root" "dan" "@wheel"];
      substituters = [
        "https://hyprland.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://pre-commit-hooks.cachix.org"
        "https://danielgafni.cachix.org"
        "https://nix-community.cachix.org"
        "https://anyrun.cachix.org"
        "https://chaotic-nyx.cachix.org/"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        "danielgafni.cachix.org-1:ZdXJoJEqeiGGOf/MtAiocqj7/vvFbA2MWFVwopJ2WQM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8"
      ];
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };

    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 30d";
    # };
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
        package = pkgs.nerd-fonts.fira-code;
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

  # networking.extraHosts = ''
  #   127.0.0.1 services.local
  # '';

  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          # Listening Address
          http_addr = "127.0.0.1";
          # and Port
          http_port = 3000;
          # Grafana needs to know on which domain and URL it's running
          # domain = "services.local";
          # root_url = "https://services.local/grafana/"; # Not needed if it is `https://your.domain/`
          # serve_from_sub_path = true;
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          # "Built-in" datasources can be provisioned - c.f. https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources
          {
            name = "Prometheus";
            type = "prometheus";
            uid = "prometheus";
            url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
            isDefault = true;
          }
        ];
        dashboards.settings = {
          providers = [
            {
              name = "Default";
              options.path = "/etc/grafana/dashboards";
            }
          ];
        };
      };
    };
    prometheus = {
      enable = true;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            # "process"
          ];
        };
        smartctl.enable = true;
      };
      retentionTime = "14d";
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];
            }
          ];
        }
        {
          job_name = "smartctl";
          static_configs = [
            {
              targets = ["localhost:${toString config.services.prometheus.exporters.smartctl.port}"];
              # labels = {
              #   instance = "localhost";
              # };
            }
          ];
        }
      ];
    };
    tailscale = {
      enable = true;
      extraUpFlags = [
        "--accept-routes true"
      ];
    };
    automatic-timezoned.enable = true;
    # login screen
    greetd = {
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

    # mullvad has broken all network for me once!
    # disabling it until better times
    mullvad-vpn.enable = false;
  };

  location.provider = "geoclue2";

  # Select internationalisation properties.
  i18n.defaultLocale = "C.UTF-8";
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
    # etc."greetd/environments".text = ''
    #   Hyprland
    # '';
    etc = {
      "greetd/environments".text = ''
        Hyprland
      '';

      "grafana/dashboards/smartctl.json" = {
        source = ./. + "/grafana-dashboards/smartctl-v1.json";
        group = "grafana";
        user = "grafana";
      };

      "grafana/dashboards/node-exporter.json" = {
        source = ./. + "/grafana-dashboards/node-exporter-v1.json";
        group = "grafana";
        user = "grafana";
      };
    };

    systemPackages = with pkgs; [
      gnumake
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
      brightnessctl
      pavucontrol
      direnv
      (python310.withPackages (ps:
        with ps; [
          pipx
          pre-commit
        ]))
      nix-output-monitor
      amazon-ecr-credential-helper
      geoclue2 # for localtimed
    ];
  };

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = ["--all"];
    };
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    zsh.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # python 3.10
        python310
      ];
    };
    steam = {
      enable = true;
    };
    # nh is a better Nix CLI: https://github.com/viperML/nh
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 30d --keep 10";
      flake = "/home/dan/nixos";
    };
  };

  services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  #services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; # try this driver)
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090; # or this one

  services.pcscd.enable = true;

  # Screen Sharing
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      #pkgs.xdg-desktop-portal-hyprland
    ];
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
  };

  # update nix index for comma every week
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 0 * * 6      dan    nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes' >> /tmp/update-comma-index.log"
    ];
  };
}
