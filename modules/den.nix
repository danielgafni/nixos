{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.den.flakeModule];

  options.hostData = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };
  options.userData = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };

  config = {
    den = {
      # Schema
      schema.user.classes = lib.mkDefault [];

      # Global defaults
      default = {
        homeManager = {
          home.stateVersion = "22.11";
          # External HM modules
          # NOTE: stylix HM module excluded - its nixos-icons overlay causes infinite
          # recursion with embedded HM. NixOS-level stylix still works. GTK theming
          # handled via catppuccin instead.
          imports = [
            inputs.catppuccin.homeModules.catppuccin
            inputs.nixvim.homeModules.nixvim
            inputs.sops-nix.homeManagerModules.sops
            # inputs._1password-shell-plugins.hmModules.default
            inputs.vicinae.homeManagerModules.default
            # Custom HM program modules
            ./_packages/nebius-cli.nix
            ./_packages/stax.nix
            ./_packages/waystt.nix
            # HM options for host/user data (works for both embedded and standalone HM)
            ({lib, ...}: {
              options.my = {
                hostSettings = lib.mkOption {
                  type = lib.types.attrs;
                  default = {};
                };
                userConfig = lib.mkOption {
                  type = lib.types.attrs;
                  default = {};
                };
              };
            })
          ];
          nixpkgs.config.allowUnfree = true;
        };
        nixos = {
          system.stateVersion = lib.mkDefault "23.11";
          nixpkgs.config.allowUnfree = true;
          # External NixOS modules
          imports = [
            inputs.catppuccin.nixosModules.catppuccin
            inputs.stylix.nixosModules.stylix
            inputs.sops-nix.nixosModules.sops
          ];
        };
        darwin.system.stateVersion = lib.mkDefault 6;
      };

      # Inject data into standalone homes via parametric dispatch
      ctx.home.includes = [
        ({home, ...}: let
          parts = lib.splitString "@" home.name;
          userName = builtins.elemAt parts 0;
          hostName = builtins.elemAt parts 1;
        in {
          homeManager = {
            my.hostSettings = config.hostData.${hostName} or {};
            my.userConfig = config.userData.${userName} or {};
          };
        })
      ];

      # Disable embedded HM — all hosts use standalone home-manager
      ctx.host.into.hm-host = lib.mkForce (_: []);

      # Host declarations
      hosts = {
        x86_64-linux = {
          DanPC.users.dan.aspect = "dan-linux";
          framnix.users.dan.aspect = "dan-linux";
          framnix.users.underdel.aspect = "underdel-linux";
        };
        # MacBook has no .users — darwin manages users via macOS, not nix-darwin.
        # NixOS hosts need .users for OS-level user creation (define-user, primary-user).
        # Home-manager is standalone for all hosts (see den.homes below).
        aarch64-darwin.MacBook = {};
      };

      # Standalone home-manager configurations
      homes = {
        x86_64-linux = {
          "dan@DanPC".aspect = "dan-linux";
          "dan@framnix".aspect = "dan-linux";
          "underdel@framnix".aspect = "underdel-linux";
        };
        aarch64-darwin."dan@MacBook".aspect = "dan-darwin";
      };
    };

    # Host data lookup table
    hostData = {
      DanPC = let
        darkAfterSeconds = 60 * 5;
        lockAfterSeconds = 60 * 15;
      in rec {
        hyprlock.monitor = "HDMI-A-2";
        ui.scale = 1.5;
        scaled = x: (builtins.ceil (x * ui.scale));
        wayland.hyprland.monitor = [",preferred,auto,${toString ui.scale}" "Unknown-1,disable"];
        wayland.hypridle.listener = [
          {
            timeout = darkAfterSeconds;
            on-timeout = ''brightnessctl -s set 15%'';
            on-resume = ''brightnessctl -r'';
          }
          {
            timeout = lockAfterSeconds;
            on-timeout = ''loginctl lock-session'';
          }
        ];
        wayland.hyprlock.auth = ["pam:enabled"];
        font = {
          titles.size = 14;
          text.size = 12;
        };
        cursor.size = 32;
        hyprpanel.modules = {
          config.cpuTemperature.sensorPath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon3/temp1_input";
          right = ["clock" "volume" "ram" "cpu" "storage" "cputemp" "systray" "hypridle" "notifications" "kbinput" "power"];
        };
      };

      framnix = let
        darkAfterSeconds = 60 * 5;
        lockAfterSeconds = 60 * 15;
      in rec {
        hyprlock.monitor = "eDP-1";
        ui.scale = 1.6;
        scaled = x: (builtins.ceil (x * ui.scale));
        wayland.hyprland.monitor = [",preferred,auto,${toString ui.scale}"];
        wayland.hyprlock.auth = ["pam:enabled" "fingerprint:enabled"];
        wayland.hypridle.listener = [
          {
            timeout = darkAfterSeconds;
            on-timeout = ''brightnessctl -s set 15%'';
            on-resume = ''brightnessctl -r'';
          }
          {
            timeout = darkAfterSeconds;
            on-timeout = ''brightnessctl -sd platform::kbd_backlight set 0'';
            on-resume = ''brightnessctl -rd platform::kbd_backlight'';
          }
          {
            timeout = lockAfterSeconds + 30;
            on-timeout = ''hyprctl dispatch dpms off'';
            on-resume = ''hyprctl dispatch dpms on'';
          }
        ];
        font = {
          titles.size = 14;
          text.size = 12;
        };
        cursor.size = 12;
        hyprpanel = {
          settings = {};
          modules = {
            config.cpuTemperature.sensorPath = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
            right = ["clock" "volume" "network" "bluetooth" "cputemp" "systray" "hypridle" "notifications" "battery" "kbinput" "power"];
          };
        };
      };

      MacBook = {
        font = {
          titles.size = 16;
          text.size = 14;
        };
        cursor.size = 24;
      };
    };

    # User data lookup table
    userData = {
      dan = rec {
        email = "danielgafni16@gmail.com";
        fullName = "Daniel Gafni";
        git = {
          user = {
            name = "danielgafni";
            inherit email;
          };
          signingkey = "2DD3012F76C19D80";
        };
        hyprland.autostart = [
          {
            workspace = "2";
            program = "slack";
          }
          {
            workspace = "2";
            program = "telegram-desktop";
          }
          {
            workspace = "1";
            program = "google-chrome-stable";
          }
          {
            workspace = "3";
            program = "zeditor";
          }
        ];
      };
      underdel = {
        email = "linagafni@gmail.com";
        fullName = "Lina Gafni";
        hyprland.autostart = [];
      };
    };
  };
}
