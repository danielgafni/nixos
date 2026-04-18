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
      toStr = builtins.toString;
      mkAutostartEntry = {
        program,
        workspace,
      }: "[workspace ${workspace} silent] ${program}";
      mkAutostartList = entries: (map mkAutostartEntry entries);
      # Generate Hyprland workspace binding lines from shared keymap data.
      mkWorkspaceLines = {
        mod,
        dispatcher,
      }:
        lib.concatMapStringsSep "\n" (w: "bind=${mod},${w.key},${dispatcher},${toStr w.workspace}") keymap.workspaces;
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

        plugins = [
          # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
        ];
        systemd.variables = ["--all"];
        settings = {
          "$mod" = "SUPER";
          monitor = hd.wayland.hyprland.monitor or [",preferred,auto,1"];
          cursor = {
            no_hardware_cursors = true;
          };
          input = {
            kb_layout = "us,ru";
            kb_variant = ",";
            kb_options = "grp:alt_shift_toggle";

            sensitivity = 0.3;

            touchpad = {
              natural_scroll = "yes";
              scroll_factor = 0.7;
            };
          };

          gestures = {
            workspace_swipe_touch = "yes";
          };

          general = {
            resize_on_border = true;
            gaps_in = 3;
            gaps_out = 3;
            border_size = 2;
            "col.active_border" = "rgba(88c0d0ff) rgba(b48eadff) rgba(ebcb8bff) rgba(a3be8cff) 45deg";
            "col.inactive_border" = "0xff434c5e";
          };
          decoration = {
            shadow = {
              enabled = true;
              range = 20;
              render_power = 3;
              color = "0xee1a1a1a";
              color_inactive = "0xee1a1a1a";
            };
            rounding = 10;

            blur = {
              enabled = true;
              size = 5;
              passes = 3;
              noise = 0.05;
              xray = false;
            };
          };
          group = {
            "col.border_inactive" = "0xff89dceb";
            "col.border_active" = "rgba(88c0d0ff) rgba(b48eadff) rgba(ebcb8bff) rgba(a3be8cff) 45deg";
          };
          misc = {
            enable_swallow = true;
            animate_manual_resizes = true;
            animate_mouse_windowdragging = true;
            disable_hyprland_logo = true;
            swallow_regex = "^(Alacritty|kitty|ghostty)$";
          };
          animations = {
            enabled = 1;

            bezier = [
              "easeOutQuint,0.22, 1, 0.36, 1"
              "easeOutSine,0.61, 1, 0.88, 1"
            ];

            animation = [
              "windows,1,2,easeOutQuint,popin"
              "border,1,20,easeOutQuint"
              "fade,1,10,easeOutQuint"
              "workspaces,1,6,easeOutQuint,slide"
              "borderangle, 1, 30, easeOutSine, loop"
            ];
          };
          layerrule = [
            "blur on, ignore_alpha 0, match:namespace gtk-layer-shell"
            "blur on, ignore_alpha 0, match:namespace notifications"
            "blur on, dim_around on, xray on, match:namespace vicinae"
          ];
          env = [
            "WLR_NO_HARDWARE_CURSORS,1"
            "XDG_SESSION_TYPE,wayland"
          ];

          exec-once =
            [
              "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP ELECTRON_OZONE_PLATFORM_HINT"
              "wl-clip-persist --clipboard regular"
            ]
            ++ mkAutostartList (ud.hyprland.autostart or []);

          windowrule = [
            "float on, match:title ^(Open Folder)$"
            "float on, match:class ^(xarchiver)$"
            ''float on, match:title ^(Вход .*)$''
            "float on, match:title ^(Enter .*)$"
            "float on, match:title (Media viewer)"
            "float on, match:initial_class ^(qimgv)$"
            "float on, match:initial_class ^(chrome-.*)$"
            "stay_focused on, match:class ^(pinentry-.*)$"
            "pin on, match:class ^(pinentry-.*)$"

            "persistent_size on, match:title (Media viewer)"

            "workspace 2, match:class ^(org.telegram.desktop)$"

            "no_screen_share on, match:class ^(org.telegram.desktop)$"
            "no_screen_share on, match:class ^(Slack)$"
            "no_screen_share on, match:class ^(discord)$"
            "no_screen_share on, match:class ^(Bitwarden)$"
            "no_screen_share on, match:class ^(1Password)$"
          ];

          bind = [
            # waystt - Speech to Text (press-to-talk)
            "SUPER_SHIFT,T,exec,pkill -9 waystt 2>/dev/null; notify-send -t 2000 '\xf0\x9f\x8e\xa4 Recording...' 'Release to transcribe (clipboard)'; waystt --pipe-to wl-copy &"
            "SUPER,T,exec,pkill -9 waystt 2>/dev/null; notify-send -t 2000 '\xf0\x9f\x8e\xa4 Recording...' 'Release to transcribe (typing)'; waystt --pipe-to wtype - &"

            # starting applications
            "$mod,RETURN,exec,ghostty"
            "$mod,${keymap.keys.fileManager},exec,ghostty -e yazi"
            "$mod,space,exec,vicinae toggle"
            ''$mod,B,exec, [float; minsize 500 500] obsidian obsidian://daily?vault=The%20Well''

            # window management
            "$mod,${keymap.keys.killWindow},killactive"
            "SUPER_SHIFT,M,exit"
            "$mod,${keymap.keys.floating},togglefloating"
            "$mod,${keymap.keys.fullscreen},fullscreen"
            "$mod,N,swapnext"
            "$mod,A,togglesplit"
            "$mod,P,pseudo,"

            # screenshots
            ",Print,exec,grim - | wl-copy"
            ''SHIFT,Print,exec,grim -g "$(slurp)" - | wl-copy''
            ''CTRL_SHIFT,Print,exec,grim - | satty --filename -''

            # brightness control
            ", XF86MonBrightnessUp,     exec, brightnessctl set 10%+"
            ", XF86MonBrightnessDown,   exec, brightnessctl set 10%-"

            # volume control (for pipewire / wireplumber)
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"

            # screen locking
            "$mod,${keymap.keys.lock},exec,grim -o ${hd.hyprlock.monitor or "eDP-1"} /tmp/screenshot.png && (pidof hyprlock || hyprlock)"
            # hyprland management
            "$mod,R,exec,hyprctl reload"
          ];

          # move and resize windows with the mouse cursor
          bindm = [
            "$mod,mouse:272,movewindow"
            "SHIFT_SUPER,mouse:272,resizewindow"
          ];

          dwindle = {
            pseudotile = 1;
            force_split = 0;
          };

          master = {};

          plugin = [
            {
              hyprexpo = {
                columns = 3;
                gap_size = 5;
                bg_col = "rgb(111111)";
                workspace_method = "center current";

                enable_gesture = true;
                gesture_fingers = 3;
                gesture_distance = 300;
                gesture_positive = true;
              };
            }
          ];
        };

        extraConfig = ''
          debug:disable_logs = false

          # waystt - Release to stop recording and transcribe
          bindr=SUPER,T,exec,pkill --signal SIGUSR1 waystt
          bindr=SUPER_SHIFT,T,exec,pkill --signal SIGUSR1 waystt

          # special workspace
          bind=CTRL_SUPER,W,exec,hyprctl dispatch movetoworkspace special
          bind=SUPER,W,workspace,special
          bind=SHIFT_SUPER,W,exec, hyprctl dispatch togglespecialworkspace ""

          # navigation between windows
          bind=$mod,left,movefocus,l
          bind=$mod,right,movefocus,r
          bind=$mod,up,movefocus,u
          bind=$mod,down,movefocus,d

          # workspace selection
          ${mkWorkspaceLines {
            mod = "$mod";
            dispatcher = "workspace";
          }}

          # move window to workspace
          ${mkWorkspaceLines {
            mod = "CTRL_SUPER";
            dispatcher = "movetoworkspace";
          }}

          bind=$mod,mouse_down,workspace,e+1
          bind=$mod,mouse_up,workspace,e-1

          bind=$mod,g,togglegroup
          bind=$mod,${keymap.keys.cycleWindowInGroup},changegroupactive
        '';
      };
    };
  };
}
