{
  lib,
  pkgs,
  host-settings,
  ...
}: {
  home = {
    packages = with pkgs; [
      hyprcursor # catppuccin-nix will automatically set the cursor theme
    ];
    sessionVariables = {
      HYPRCURSOR_SIZE = lib.mkForce (toString host-settings.cursor.size);
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    catppuccin.enable = true;
    plugins = [
      # TODO: re-enable once it builds correctly
      # inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails
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
        kb_variant = "ffffff";
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
        workspace_swipe = "yes";
        workspace_swipe_fingers = 4;
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
      misc = {
        enable_swallow = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        disable_hyprland_logo = true;
        # this should spawn a window right on top of the terminal
        # but I couldn't get it working yet
        swallow_regex = "^(Alacritty|kitty)$";
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
        # rules for Mako notifications
        "blur, notifications"
        "ignorealpha 0, notifications" # remove blurred surface around borders

        # wofi
        "blur, wofi"
        "ignorealpha 30, wofi" # remove blurred surface around borders
        "dimaround, wofi"
      ];
      env = [
        "WLR_NO_HARDWARE_CURSORS,1"
        "XDG_SESSION_TYPE,wayland"
      ];
      exec-once = [
        #"mako"  # using hyprlanel instead
        # "eww daemon --restart && eww close-all && eww open-many bar"  # using hyprlanel instead
        "hyprpanel"
        "${pkgs.hypridle}/bin/hypridle" # idle event trigger
      ];
      plugin = [
        # TODO: re-enable once it builds correctly
        # {
        #   hyprtrails = {
        #     color = "$sapphire";
        #   };
        # }
      ];

      windowrulev2 = [
        "float,title:^(Open Folder)$" # File Shooser
        "float,class:xarchiver"
        "float,title:Bitwarden"
      ];
    };

    extraConfig = ''
      debug:disable_logs = false

      exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once=systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

      # polkit (the app which asks for the root password access)
      exec-once=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

      group {
        col.border_inactive=0xff89dceb
      	col.border_active=rgba(88c0d0ff) rgba(b48eadff) rgba(ebcb8bff) rgba(a3be8cff) 45deg

      }

      dwindle {
              pseudotile=1 # enable pseudotiling on dwindle
      	force_split=0
      }

      master {
      }



      # example window rules
      # for windows named/classed as abc and xyz
      #windowrule=move 69 420,abc
      windowrule=move center,title:^(fly_is_kitty)$
      windowrule=size 800 500,title:^(fly_is_kitty)$
      windowrule=animation slide,title:^(all_is_kitty)$
      windowrule=float,title:^(all_is_kitty)$
      #windowrule=tile,xy
      windowrule=tile,title:^(kitty)$
      windowrule=float,title:^(fly_is_kitty)$
      windowrule=float,title:^(clock_is_kitty)$
      windowrule=size 418 234,title:^(clock_is_kitty)$
      #windowrule=pseudo,abc
      #windowrule=monitor 0,xyz

      # brightness control
      bind = , XF86MonBrightnessUp,     exec, brightnessctl set 10%+
      bind = , XF86MonBrightnessDown,   exec, brightnessctl set 10%-

      # pulseaudio volume control
      #bind = , xf86audioraisevolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
      #bind = , xf86audiolowervolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%

      # pipewire / wireplumber
      bind =, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+
      bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-


      # move and resize windows with the mouse cursor
      bindm=SUPER,mouse:272,movewindow
      bindm=SHIFT_SUPER,mouse:272,resizewindow

      # move the active window to the next position
      bind=SUPER,N,swapnext,
      # make the active window the main
      bind=SUPER,A,togglesplit,

      # screenshots
      bind=,Print,exec,grim - | wl-copy
      bind=SHIFT,Print,exec,grim -g "$(slurp)" - | wl-copy

      bind=SUPER,RETURN,exec,kitty --title kitty
      bind=SUPER,Q,killactive,
      bind=SUPER,M,exit,
      bind=SUPER,R,exec,hyprctl reload
      bind=SUPER,E,exec,kitty --title kitty -e yazi
      bind=SUPER,S,togglefloating,
      bind=SUPER,F,fullscreen,

      # TODO: exlore running with --normal-window for Hyprland theming purposes
      bind=SUPER,space,exec,wofi --show drun -i -I -m -G -o DP-3 --width 55% --height 50%
      bind=SUPER,P,pseudo,

      # special workspace
      bind=CTRL_SUPER,W,exec,hyprctl dispatch movetoworkspace special
      bind=SUPER,W,workspace,special
      bind=SHIFT_SUPER,W,exec, hyprctl dispatch togglespecialworkspace ""

      # screen locking
      bind=SUPER,L,exec,grim -o HDMI-A-1 /tmp/screenshot.png && hyprlock

      # disable notifications
      bind=SHIFT_SUPER,N,exec,makoctl mode -t do-not-disturb

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

      # rec
      #bind=CTRL,1,exec,kitty --title fly_is_kitty --hold cava
      #bind=CTRL,2,exec,code-insiders
      #bind=CTRL,3,exec,kitty --single-instance --hold donut.c
      #bind=CTRL,4,exec,kitty --title clock_is_kitty --hold tty-clock -C5
    '';
  };
}
