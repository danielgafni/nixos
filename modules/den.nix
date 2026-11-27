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
            ./_packages/aviator-cli.nix
            ./_packages/nebius-cli.nix
            ./_packages/stax.nix
            ./_packages/waystt.nix
            ./_packages/commandshift.nix
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
                keymap = lib.mkOption {
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
          # NixOS theming is handled by stylix; keep catppuccin's port
          # auto-enrollment off and set it explicitly to silence the
          # upcoming-default warning.
          catppuccin.autoEnable = false;
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
            my = {
              hostSettings = config.hostData.${hostName} or {};
              userConfig = config.userData.${userName} or {};
              inherit (config) keymap;
            };
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
        # Shape matches Hyprland 0.57's Lua hl.monitor({...}) table.
        wayland.hyprland.monitor = [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            inherit (ui) scale;
          }
          {
            output = "Unknown-1";
            disabled = true;
          }
        ];
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
        wayle.modules = {
          # k10temp on this box; `temp-sensor` takes a sensors(1) label, not a
          # sysfs path. cputemp is folded into the cpu module's format.
          cpu.tempSensor = "Tctl";
          right = ["clock" "volume" "ram" "cpu" "storage" "systray" "idle-inhibit" "notifications" "keyboard-input" "power"];
        };
      };

      framnix = let
        darkAfterSeconds = 60 * 5;
        lockAfterSeconds = 60 * 15;
      in rec {
        hyprlock.monitor = "eDP-1";
        ui.scale = 1.6;
        scaled = x: (builtins.ceil (x * ui.scale));
        wayland.hyprland.monitor = [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            inherit (ui) scale;
          }
        ];
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
        wayle.modules = {
          # coretemp on this box. Unverified from DanPC — if the label differs,
          # `sensors` lists it, or set "auto".
          cpu.tempSensor = "Package id 0";
          right = ["clock" "volume" "network" "bluetooth" "cpu" "systray" "idle-inhibit" "notifications" "battery" "keyboard-input" "power"];
        };
      };

      MacBook = {
        font = {
          titles.size = 18;
          text.size = 17;
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
