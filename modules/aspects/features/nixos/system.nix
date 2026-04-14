{
  den,
  inputs,
  ...
}: {
  den.aspects.nixos-system = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: {
      nix = {
        settings = {
          trusted-users = ["root" "dan" "@wheel"];
          substituters = [
            "https://hyprland.cachix.org"
            "https://nixpkgs-wayland.cachix.org"
            "https://pre-commit-hooks.cachix.org"
            "https://danielgafni.cachix.org"
            "https://nix-community.cachix.org"
            "https://chaotic-nyx.cachix.org/"
            "https://vicinae.cachix.org"
            "https://devenv.cachix.org"
          ];
          trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
            "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
            "danielgafni.cachix.org-1:ZdXJoJEqeiGGOf/MtAiocqj7/vvFbA2MWFVwopJ2WQM="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8"
            "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
        };
      };

      boot = {
        loader.systemd-boot = {
          enable = true;
          configurationLimit = 5;
        };
        loader.efi.canTouchEfiVariables = true;
        kernelModules = ["iptable_nat" "iptable_filter" "xt_nat"];
      };

      networking = {
        useDHCP = lib.mkDefault true;
        networkmanager = {
          enable = true;
          settings.main.authPolkit = false;
          insertNameservers = ["100.100.100.100" "1.1.1.1" "8.8.8.8"];
        };
        proxy.noProxy = "127.0.0.1,localhost";
        firewall.enable = false;
        firewall.checkReversePath = false;
      };

      system.nssDatabases.hosts = lib.mkAfter ["[!UNAVAIL=return]"];

      users.defaultUserShell = pkgs.zsh;

      stylix = {
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        fonts = {
          sansSerif = {
            package = pkgs.cabin;
            name = "Cabin";
          };
          serif = config.stylix.fonts.sansSerif;
          monospace = {
            package = pkgs.maple-mono.NF;
            name = "Maple Mono NF";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };
      };

      fonts = {
        fontDir.enable = true;
        fontconfig.enable = true;
      };

      services = {
        grafana = {
          enable = false;
          settings = {
            server = {
              http_addr = "127.0.0.1";
              http_port = 3123;
            };
          };
          provision = {
            enable = true;
            datasources.settings.datasources = [
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
          enable = false;
          exporters = {
            node = {
              enable = true;
              enabledCollectors = [
                "systemd"
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
        greetd = {
          enable = true;
          settings = {
            default_session.command = ''
              ${pkgs.greetd.tuigreet}/bin/tuigreet \
                --time \
                --asterisks \
                --user-menu \
                --cmd start-hyprland
            '';
          };
        };
        printing.enable = true;
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
        };
        mullvad-vpn.enable = false;
      };

      location.provider = "geoclue2";

      i18n.defaultLocale = "C.UTF-8";
      console = {
        useXkbConfig = true;
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
        pathsToLink = ["/share/zsh"];
        sessionVariables = {
          "NIXOS_OZONE_WL" = "1";
        };
        shells = with pkgs; [zsh];
        etc = {
          "greetd/environments".text = ''
            start-hyprland
          '';

          "grafana/dashboards/smartctl.json" = {
            source = ./data/grafana-dashboards/smartctl-v1.json;
            group = "grafana";
            user = "grafana";
          };

          "grafana/dashboards/node-exporter.json" = {
            source = ./data/grafana-dashboards/node-exporter-v1.json;
            group = "grafana";
            user = "grafana";
          };
        };

        systemPackages = with pkgs; [
          inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
          gnumake
          cachix
          zsh
          starship
          ripgrep
          bat
          eza
          fd
          dust
          dua
          btop
          zellij
          vim
          neovim
          wget
          curl
          lynx
          brightnessctl
          pavucontrol
          direnv
          (python3.withPackages (ps:
            with ps; [
              pre-commit
            ]))
          nix-output-monitor
          amazon-ecr-credential-helper
          geoclue2
        ];
      };

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

      programs = {
        hyprland = {
          enable = true;
          xwayland.enable = true;
        };
        zsh.enable = true;
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            python312
          ];
        };
        steam = {
          enable = true;
        };
        nh = {
          enable = true;
          clean.enable = true;
          clean.extraArgs = "--keep-since 15d --keep 5";
          flake = "/home/dan/nixos";
        };
        zoom-us = {
          enable = true;
        };
      };

      services.fprintd.enable = true;
      services.pcscd.enable = true;

      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [
              "hyprland"
              "gtk"
            ];
          };
          hyprland = {
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
          };
        };
      };

      services.cron = {
        enable = true;
        systemCronJobs = [
          "0 0 * * 6      dan    nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes' >> /tmp/update-comma-index.log"
        ];
      };
    };
  };
}
