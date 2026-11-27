{den, ...}: {
  den.aspects.hyprland = {
    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: let
      hd = config.my.hostSettings;
      ud = config.my.userConfig;
      inherit (config.my) keymap;
      mod = "SUPER";

      gradient = {
        colors = [
          "rgba(88c0d0ff)"
          "rgba(b48eadff)"
          "rgba(ebcb8bff)"
          "rgba(a3be8cff)"
        ];
        angle = 45;
      };

      # Hyprland 0.57 configures via Lua, so binds are emitted as hl.bind calls
      # rather than data. Workspace binds come from the shared keymap table.
      mkWorkspaceBinds = {
        prefix,
        dispatcher,
      }:
        lib.concatMapStringsSep "\n" (
          w: ''hl.bind("${prefix} + ${w.key}", ${dispatcher}({workspace = ${toString w.workspace}}))''
        )
        keymap.workspaces;

      autostartLines = lib.concatMapStringsSep "\n" (
        e: ''hl.exec_cmd("[workspace ${e.workspace} silent] ${e.program}")''
      ) (ud.hyprland.autostart or []);
    in {
      home = {
        packages = with pkgs; [
          hyprcursor
          wl-clip-persist
        ];
        sessionVariables = {
          HYPRCURSOR_SIZE = lib.mkForce (toString (hd.cursor.size or 24));
          ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        };
      };

      services = {
        hyprpolkitagent.enable = true;
      };

      xdg.configFile."electron-flags.conf" = {
        text = ''
          --enable-features=UseOzonePlatform
          --ozone-platform=wayland
        '';
      };

      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        # Hyprland 0.57 dropped hyprlang as the config language; the compositor
        # parses ~/.config/hypr/hyprland.lua as Lua now.
        configType = "lua";

        # No hyprland-plugins flake input exists here; if hyprexpo is wanted
        # again, use pkgs.hyprlandPlugins.hyprexpo and re-add its config block.
        plugins = [];
        systemd.variables = ["--all"];

        # Everything below renders as `hl.<name>(...)` calls. `curve` is in
        # home-manager's importantPrefixes, so curves are emitted before the
        # animations that reference them by name.
        settings = {
          monitor =
            hd.wayland.hyprland.monitor
            or [
              {
                output = "";
                mode = "preferred";
                position = "auto";
                scale = "auto";
              }
            ];

          env = [
            {_args = ["WLR_NO_HARDWARE_CURSORS" "1"];}
            {_args = ["XDG_SESSION_TYPE" "wayland"];}
          ];

          config = {
            cursor.no_hardware_cursors = true;

            input = {
              kb_layout = "us,ru";
              kb_variant = ",";
              kb_options = "grp:alt_shift_toggle";
              sensitivity = 0.3;
              touchpad = {
                natural_scroll = true;
                scroll_factor = 0.7;
              };
            };

            general = {
              resize_on_border = true;
              gaps_in = 3;
              gaps_out = 3;
              border_size = 2;
              col = {
                active_border = gradient;
                inactive_border = "rgba(434c5eff)";
              };
            };

            decoration = {
              rounding = 10;
              shadow = {
                enabled = true;
                range = 20;
                render_power = 3;
                color = "rgba(1a1a1aee)";
                color_inactive = "rgba(1a1a1aee)";
              };
              blur = {
                enabled = true;
                size = 5;
                passes = 3;
                noise = 0.05;
                xray = false;
              };
            };

            group.col = {
              border_inactive = "rgba(89dcebff)";
              border_active = gradient;
            };

            misc = {
              enable_swallow = true;
              animate_manual_resizes = true;
              animate_mouse_windowdragging = true;
              disable_hyprland_logo = true;
              swallow_regex = "^(Alacritty|kitty|ghostty)$";
            };

            dwindle.force_split = 0;
            animations.enabled = true;
            debug.disable_logs = false;
          };

          curve = [
            {
              _args = [
                "easeOutQuint"
                {
                  type = "bezier";
                  points = [[0.22 1] [0.36 1]];
                }
              ];
            }
            {
              _args = [
                "easeOutSine"
                {
                  type = "bezier";
                  points = [[0.61 1] [0.88 1]];
                }
              ];
            }
          ];

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 2;
              bezier = "easeOutQuint";
              style = "popin";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 20;
              bezier = "easeOutQuint";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 10;
              bezier = "easeOutQuint";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 6;
              bezier = "easeOutQuint";
              style = "slide";
            }
            {
              leaf = "borderangle";
              enabled = true;
              speed = 30;
              bezier = "easeOutSine";
              style = "loop";
            }
          ];

          layer_rule = [
            {
              name = "blur-gtk-layer-shell";
              match.namespace = "gtk-layer-shell";
              blur = true;
              ignore_alpha = 0;
            }
            {
              name = "blur-notifications";
              match.namespace = "notifications";
              blur = true;
              ignore_alpha = 0;
            }
            {
              name = "blur-vicinae";
              match.namespace = "vicinae";
              blur = true;
              dim_around = true;
              xray = true;
            }
          ];

          window_rule = [
            {
              name = "float-open-folder";
              match.title = "^(Open Folder)$";
              float = true;
            }
            {
              name = "float-xarchiver";
              match.class = "^(xarchiver)$";
              float = true;
            }
            {
              name = "float-enter-ru";
              match.title = "^(Вход .*)$";
              float = true;
            }
            {
              name = "float-enter-en";
              match.title = "^(Enter .*)$";
              float = true;
            }
            {
              name = "float-media-viewer";
              match.title = "(Media viewer)";
              float = true;
            }
            {
              name = "float-qimgv";
              match.initial_class = "^(qimgv)$";
              float = true;
            }
            {
              name = "float-chrome";
              match.initial_class = "^(chrome-.*)$";
              float = true;
            }
            {
              name = "pinentry-stay-focused";
              match.class = "^(pinentry-.*)$";
              stay_focused = true;
            }
            {
              name = "pinentry-pin";
              match.class = "^(pinentry-.*)$";
              pin = true;
            }
            {
              name = "media-viewer-persistent-size";
              match.title = "(Media viewer)";
              persistent_size = true;
            }
            {
              name = "telegram-workspace";
              match.class = "^(org.telegram.desktop)$";
              workspace = 2;
            }
            {
              name = "no-screen-share-telegram";
              match.class = "^(org.telegram.desktop)$";
              no_screen_share = true;
            }
            {
              name = "no-screen-share-slack";
              match.class = "^(Slack)$";
              no_screen_share = true;
            }
            {
              name = "no-screen-share-discord";
              match.class = "^(discord)$";
              no_screen_share = true;
            }
            {
              name = "no-screen-share-bitwarden";
              match.class = "^(Bitwarden)$";
              no_screen_share = true;
            }
            {
              name = "no-screen-share-1password";
              match.class = "^(1Password)$";
              no_screen_share = true;
            }
          ];
        };

        extraConfig = ''
          -- Autostart. home-manager emits its own hyprland.start handler for the
          -- systemd activation environment; this one carries user programs.
          hl.on("hyprland.start", function()
            hl.exec_cmd("wl-clip-persist --clipboard regular")
          ${autostartLines}
          end)

          -- waystt - speech to text (press to talk, release to transcribe)
          hl.bind("${mod} + SHIFT + T", hl.dsp.exec_cmd([[pkill -9 waystt 2>/dev/null; notify-send -t 2000 '🎤 Recording...' 'Release to transcribe (clipboard)'; waystt --pipe-to wl-copy &]]))
          hl.bind("${mod} + T",         hl.dsp.exec_cmd([[pkill -9 waystt 2>/dev/null; notify-send -t 2000 '🎤 Recording...' 'Release to transcribe (typing)'; waystt --pipe-to wtype - &]]))
          hl.bind("${mod} + SHIFT + T", hl.dsp.exec_cmd("pkill --signal SIGUSR1 waystt"), {release = true})
          hl.bind("${mod} + T",         hl.dsp.exec_cmd("pkill --signal SIGUSR1 waystt"), {release = true})

          -- starting applications
          hl.bind("${mod} + RETURN", hl.dsp.exec_cmd("ghostty"))
          hl.bind("${mod} + ${keymap.keys.fileManager}", hl.dsp.exec_cmd("ghostty -e yazi"))
          hl.bind("${mod} + space", hl.dsp.exec_cmd("vicinae toggle"))
          hl.bind("${mod} + B", hl.dsp.exec_cmd([[[float; minsize 500 500] obsidian obsidian://daily?vault=The%20Well]]))

          -- window management
          hl.bind("${mod} + ${keymap.keys.killWindow}", hl.dsp.window.close())
          hl.bind("${mod} + SHIFT + M", hl.dsp.exit())
          hl.bind("${mod} + ${keymap.keys.floating}", hl.dsp.window.float({action = "toggle"}))
          hl.bind("${mod} + ${keymap.keys.fullscreen}", hl.dsp.window.fullscreen())
          hl.bind("${mod} + N", hl.dsp.window.swap({next = true}))
          hl.bind("${mod} + A", hl.dsp.layout("togglesplit"))
          hl.bind("${mod} + P", hl.dsp.window.pseudo())

          -- screenshots
          hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))
          hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]))
          hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd("grim - | satty --filename -"))

          -- brightness control
          hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"), {locked = true, repeating = true})
          hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), {locked = true, repeating = true})

          -- volume control (for pipewire / wireplumber)
          hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {locked = true})
          hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"), {locked = true, repeating = true})
          hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"), {locked = true, repeating = true})

          -- screen locking
          hl.bind("${mod} + ${keymap.keys.lock}", hl.dsp.exec_cmd("grim -o ${hd.hyprlock.monitor or "eDP-1"} /tmp/screenshot.png && (pidof hyprlock || hyprlock)"))

          -- hyprland management
          hl.bind("${mod} + R", hl.dsp.reload_config())

          -- move and resize windows with the mouse cursor
          hl.bind("${mod} + mouse:272", hl.dsp.window.drag(), {mouse = true})
          hl.bind("SHIFT + ${mod} + mouse:272", hl.dsp.window.resize(), {mouse = true})

          -- special workspace
          hl.bind("CTRL + ${mod} + W", hl.dsp.window.move({workspace = "special"}))
          hl.bind("${mod} + W", hl.dsp.focus({workspace = "special"}))
          hl.bind("SHIFT + ${mod} + W", hl.dsp.workspace.toggle_special(""))

          -- navigation between windows
          hl.bind("${mod} + left", hl.dsp.focus({direction = "left"}))
          hl.bind("${mod} + right", hl.dsp.focus({direction = "right"}))
          hl.bind("${mod} + up", hl.dsp.focus({direction = "up"}))
          hl.bind("${mod} + down", hl.dsp.focus({direction = "down"}))
          hl.bind("${mod} + h", hl.dsp.focus({direction = "left"}))
          hl.bind("${mod} + l", hl.dsp.focus({direction = "right"}))
          hl.bind("${mod} + k", hl.dsp.focus({direction = "up"}))
          hl.bind("${mod} + j", hl.dsp.focus({direction = "down"}))

          -- workspace selection
          ${mkWorkspaceBinds {
            prefix = mod;
            dispatcher = "hl.dsp.focus";
          }}

          -- move window to workspace
          ${mkWorkspaceBinds {
            prefix = "CTRL + ${mod}";
            dispatcher = "hl.dsp.window.move";
          }}

          hl.bind("${mod} + mouse_down", hl.dsp.focus({workspace = "e+1"}))
          hl.bind("${mod} + mouse_up", hl.dsp.focus({workspace = "e-1"}))

          -- groups
          hl.bind("${mod} + g", hl.dsp.group.toggle())
          hl.bind("${mod} + ${keymap.keys.cycleWindowInGroup}", hl.dsp.group.next())
        '';
      };
    };
  };
}
