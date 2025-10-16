{
  inputs,
  lib,
  pkgs,
  # a custom object specific to my setup
  host-settings,
  # an custom object specific to my setup
  userConfig,
  ...
}: let
  mkAutostartEntry = {
    program,
    workspace,
  }: "[workspace ${workspace} silent] ${program}";
  mkAutostartList = entries: (map mkAutostartEntry entries);
in {
  home = {
    packages = with pkgs; [
      hyprcursor # catppuccin-nix will automatically set the cursor theme
      wl-clip-persist # clipboard persistence for Wayland
    ];
    sessionVariables = {
      HYPRCURSOR_SIZE = lib.mkForce (toString host-settings.cursor.size); # this doesn't seem to affect hyprland. TODO: set the var in hyprland config
      ELECTRON_OZONE_PLATFORM_HINT = "wayland"; # helps with electron apps like 1password
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

    # package and portportalPackage are set to null
    # because they are installed via NixOS instead of Home Manager
    # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#using-the-home-manager-module-with-nixos
    package = null;
    portalPackage = null;

    plugins = [
      # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
    ];
    systemd.variables = ["--all"];
    settings = {
      inherit (host-settings.wayland.hyprland) monitor;
      cursor = {
        # needed for nvidia
        no_hardware_cursors = true;
      };
      input = {
        kb_layout = "us,ru";
        kb_variant = ",";
        kb_options = "grp:alt_shift_toggle";

        sensitivity = 0.3; # for mouse cursor

        # must click on window to move focus
        # follow_mouse=2

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
        # rotating gradeint border!
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
          size = 5; # minimum 1
          passes = 3; # minimum 1, more passes = more resource intensive.
          # Your blur "amount" is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
          # if you want heavy blur, you need to up the blur_passes.
          # the more passes, the more you can up the blur_size without noticing artifacts.
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
        # this should spawn a window right on top of the terminal
        # but I couldn't get it working yet
        swallow_regex = "^(Alacritty|kitty|ghostty)$";
      };
      animations = {
        enabled = 1;

        bezier = [
          "easeOutQuint,0.22, 1, 0.36, 1" # https://easings.net/#easeOutQuint
          "easeOutSine,0.61, 1, 0.88, 1" # https://easings.net/#easeOutSine
        ];

        animation = [
          "windows,1,2,easeOutQuint,popin"
          "border,1,20,easeOutQuint"
          "fade,1,10,easeOutQuint"
          "workspaces,1,6,easeOutQuint,slide"
          # gradient disco party borders!
          "borderangle, 1, 30, easeOutSine, loop"
        ];
      };
      layerrule = [
        # eww
        "blur, gtk-layer-shell"
        "ignorealpha 0, gtk-layer-shell" # remove blurred surface around borders

        # use `hyprctl layers` to get layer namespaces
        "blur, notifications"
        "ignorealpha 0, notifications" # remove blurred surface around borders

        # vicinae
        "blur, (vicinae)"
        "dimaround, vicinae"
        "ignorezero, (vicinae)"
      ];
      env = [
        "WLR_NO_HARDWARE_CURSORS,1"
        "XDG_SESSION_TYPE,wayland"
      ];

      # list of commands to run during Hyprland startup
      exec-once =
        [
          # import env vars set with home.sessionVariables
          "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP ELECTRON_OZONE_PLATFORM_HINT"
          "wl-clip-persist --clipboard regular"
        ]
        ++ mkAutostartList userConfig.hyprland.autostart;

      windowrulev2 = [
        "float,title:^(Open Folder)$" # File Shooser
        "float,class:xarchiver"
        "float,title:^(Вход .*)$" # chrome login in Russian
        "float,title:^(Enter .*)$" # chrome login in English
        "float,title:^*(Media viewer)$" # Telegram media viewer
        "float,initialClass:^*(qimgv)$" # image viewer
        "float,initialClass:^(chrome-.*)$"
        "stayfocused,class:^(pinentry-.*)$"
        "pin,class:^(pinentry-.*)$" # pin == show on all workspaces

        # persist window size between launches
        "persistentsize,title:^*(Media viewer)$"
        "float,initialClass:^*(qimgv)$" # image viewer

        # automatically open applications at specific workspaces
        "workspace 2,class:org.telegram.desktop"

        # forbid screensharing for sensitive apps
        "noscreenshare 1,class:org.telegram.desktop"
        "noscreenshare 1,class:Slack"
        "noscreenshare 1,class:discord"
        "noscreenshare 1,class:Bitwarden"
        "noscreenshare 1,class:1Password"
      ];

      bind = [
        # starting applications
        "SUPER,RETURN,exec,ghostty"
        "SUPER,E,exec,ghostty -e yazi"
        # application launcher
        "SUPER,space,exec,vicinae toggle"
        # open obsidian daily note
        "SUPER,B,exec, [float; minsize 500 500] obsidian obsidian://daily?vault=The%20Well"

        # window management
        "SUPER,Q,killactive"
        "SUPER_SHIFT,M,exit"
        "SUPER,S,togglefloating"
        "SUPER,F,fullscreen"
        # move the active window to the next position
        "SUPER,N,swapnext"
        # make the active window the main
        "SUPER,A,togglesplit"
        # toggle pseudo tiling mode for a window
        "SUPER,P,pseudo,"
        # start hyprexpo - an overview of all workspaces
        # "SUPER, grave, hyprexpo:expo, toggle" # can be: toggle, off/disable or on/enable

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

        # disable notifications
        # TODO: find how to do it with hyprpanel
        # "SHIFT_SUPER,N,exec,makoctl mode -t do-not-disturb"

        # screen locking
        "SUPER,L,exec,grim -o ${host-settings.hyprlock.monitor} /tmp/screenshot.png && (pidof hyprlock || hyprlock)"
        # hyprland management
        "SUPER,R,exec,hyprctl reload"
      ];

      # move and resize windows with the mouse cursor
      bindm = [
        "SUPER,mouse:272,movewindow"
        "SHIFT_SUPER,mouse:272,resizewindow"
      ];

      dwindle = {
        pseudotile = 1; # enable pseudotiling on dwindle
        force_split = 0;
      };

      master = {};

      plugin = [
        {
          hyprexpo = {
            columns = 3;
            gap_size = 5;
            bg_col = "rgb(111111)";
            workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1

            enable_gesture = true; # laptop touchpad
            gesture_fingers = 3; # 3 or 4
            gesture_distance = 300; # how far is the "max"
            gesture_positive = true; # positive = swipe down. Negative = swipe up.
          };
        }
      ];
    };

    extraConfig = ''
      debug:disable_logs = false

      # special workspace
      bind=CTRL_SUPER,W,exec,hyprctl dispatch movetoworkspace special
      bind=SUPER,W,workspace,special
      bind=SHIFT_SUPER,W,exec, hyprctl dispatch togglespecialworkspace ""

      # navigation between windows
      bind=SUPER,left,movefocus,l
      bind=SUPER,right,movefocus,r
      bind=SUPER,up,movefocus,u
      bind=SUPER,down,movefocus,d

      # workspace selection
      bind=SUPER,1,workspace,1
      bind=SUPER,2,workspace,2
      bind=SUPER,3,workspace,3
      bind=SUPER,4,workspace,4
      bind=SUPER,5,workspace,5
      bind=SUPER,6,workspace,6
      bind=SUPER,7,workspace,7
      bind=SUPER,8,workspace,8
      bind=SUPER,9,workspace,9
      bind=SUPER,0,workspace,10

      # move window to workspace
      bind=CTRL_SUPER,1,movetoworkspace,1
      bind=CTRL_SUPER,2,movetoworkspace,2
      bind=CTRL_SUPER,3,movetoworkspace,3
      bind=CTRL_SUPER,4,movetoworkspace,4
      bind=CTRL_SUPER,5,movetoworkspace,5
      bind=CTRL_SUPER,6,movetoworkspace,6
      bind=CTRL_SUPER,7,movetoworkspace,7
      bind=CTRL_SUPER,8,movetoworkspace,8
      bind=CTRL_SUPER,9,movetoworkspace,9
      bind=CTRL_SUPER,0,movetoworkspace,10

      bind=SUPER,mouse_down,workspace,e+1
      bind=SUPER,mouse_up,workspace,e-1

      bind=SUPER,g,togglegroup
      bind=SUPER,tab,changegroupactive
    '';
  };
}
