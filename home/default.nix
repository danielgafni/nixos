# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {

  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    ./shell
    ./terminals/kitty.nix
    ./eww.nix
    ./hyprpaper.nix
    ./vscode.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
      inputs.nixpkgs-wayland.overlay
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  # TODO: Set your username
  home = {
    username = "dan";
    homeDirectory = "/home/dan";
  };

  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
  programs.dircolors.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # YubiKey
    #yubioath-flutter
    yubikey-personalization-gui
    yubikey-manager

    # devops
    kubectl
    k9s
    sops
    age
    (pkgs.wrapHelm pkgs.kubernetes-helm { plugins = [ pkgs.kubernetes-helmPlugins.helm-secrets ]; })
    awscli2
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])

    # wayland/DE
    libnotify # notify-send command
    mako
    swaylock
    wofi
    waybar
    hyprpaper
    hyprpicker
    grim
    slurp
    flameshot
    wev # show wayland events
    wl-clipboard
    font-manager
    alacritty
    kitty
    ranger

    # audio
    pipewire
    wireplumber

    # CLI
    comma
    git
    curl
    wget
    zsh
    starship
    zellij
    bat
    exa
    pfetch
    neofetch
    pre-commit

    # fonts
    (
      nerdfonts.override {
         fonts = [ 
          "FiraCode"
          "DroidSansMono"
        ]; 
      }
    )
    recursive  # for eww
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf

    # messengers
    telegram-desktop
    signal-desktop
    slack
    discord

    # browsers
    google-chrome
    firefox
    lynx

    # editors & IDE            
    vim
    neovim
    helix
    jetbrains.pycharm-professional

    # Python tools
    poetry
    pyright
    mypy
    black
    ruff
    isort
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "danielgafni";
    userEmail = "danielgafni16@gmail.com";
    extraConfig = {
        commit.gpgsign = true;
        user.signingkey = "7B0740201D518DB134D5C75AB8D13360DED17662";
      };
  };

  # systemd.user,targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target"  ];

  # Wallpapers
  xdg.configFile."wallpapers" = {
    recursive = true;
    source = ./.config/wallpapers;
  };

  # Cursor
  home.pointerCursor = {
    name = "Catppuccin-Mocha-Dark-Cursors";
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 16;
  };

  # mako (notifications) config
  xdg.configFile."mako" = {
    recursive = true;
    source = ./.config/mako;
  };

  # wofi (app launcher)
  xdg.configFile."wofi" = {
    recursive = true;
    source = ./.config/wofi;
  };

  # swaylock
  xdg.configFile."swaylock" = {
    recursive = true;
    source = ./.config/swaylock;
  };
  
  xdg.configFile."helix" = {
    recursive = true;
    source = ./.config/helix;
  };

  xdg.configFile."btop" = {
    recursive = true;
    source = ./.config/btop;
  };

  # default mime apps
  # xdg.mimeApps = {
  #   enable = true;
  #   associations.added = {
  #   };
  #   defaultApplications = {
  #   };
  # };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      env = WLR_NO_HARDWARE_CURSORS,1
      exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once=systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    
      # polkit (the app which asks for the root password access)
      exec-once=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
    
      # theming
      #exec-once=gsettings set org.gnome.desktop.interface cursor-size 48
      #exec-once=gsettings set org.gnome.desktop.interface gtk-theme "Nordic"
      #exec-once=gsettings set org.gnome.desktop.wm.preferences theme "Nordic"
      #exec-once=exec-once=hyprctl setcursor Nordzy-cursors 24

      # notifications
      exec-once=mako
      # bar
      #exec-once=waybar
      # idle detection
      exec-once=swayidle -w timeout 1800 'swaylock' timeout 12000 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' before-sleep 'swaylock'
      # eww widgets
      exec-once=eww daemon --restart && eww close-all && eww open-many bar

      # blur layers (hyprctl layers to get the correct namespace)
      layerrule = blur,notifications
      layerrule = blur,wofi
      layerrule = blur,gtk-layer-shell

      #blurls=notifications
      #blurls=wofi
      #blurls=gtk-layer-shell
    
      input {
      	kb_layout=us,ru
      	kb_variant=ffffff
      	kb_options=grp:alt_shift_toggle
      	sensitivity = 0.3

      	# must click on window to move focus
      	# follow_mouse=2

      	touchpad {
      	    natural_scroll=yes
      	    scroll_factor=0.7
      	}
      }
    
      misc{
      	animate_manual_resizes true
      	enable_swallow true
      	animate_mouse_windowdragging true

      	# this should spawn a window right on top of the terminal
      	# but I couldn't get it working yet
      	#     swallow_regex ^(kitty)$

      }
    
      general {
      	sensitivity=1.0 # for mouse cursor
      	resize_on_border=true

      	gaps_in=3
      	gaps_out=3
      	border_size=2
      	col.active_border = rgba(88c0d0ff) rgba(b48eadff) rgba(ebcb8bff) rgba(a3be8cff) 45deg
      	col.inactive_border=0xff434c5e
      	apply_sens_to_raw=0 # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
      	col.group_border=0xff89dceb
      	col.group_border_active=rgba(88c0d0ff) rgba(b48eadff) rgba(ebcb8bff) rgba(a3be8cff) 45deg
      }
    
      decoration {
      	drop_shadow = true
      	shadow_range=20
      	shadow_render_power=3
      	col.shadow=0xee1a1a1a
      	col.shadow_inactive=0xee1a1a1a
      	rounding=10

      	blur {
      		enabled=true
      		size=5 # minimum 1
      		passes=3 # minimum 1, more passes = more resource intensive.
      		# Your blur "amount" is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
      		# if you want heavy blur, you need to up the blur_passes.
      		# the more passes, the more you can up the blur_size without noticing artifacts.
      		noise=0.05	
      		xray=true
      	}
      }

    

      animations {
              enabled=1
        
              bezier=easeOutQuint,0.22, 1, 0.36, 1  # https://easings.net/#easeOutQuint
              bezier=easeOutSine,0.61, 1, 0.88, 1)  # https://easings.net/#easeOutSine
    
              animation=windows,1,4,easeOutQuint,popin
              animation=border,1,20,easeOutQuint
              animation=fade,1,10,easeOutQuint
              animation=workspaces,1,6,easeOutQuint,slide
      	
      	# gradient disco party borders
              animation = borderangle, 1, 30, easeOutSine, loop
          }

      dwindle {
              pseudotile=1 # enable pseudotiling on dwindle
      	force_split=0
      }

      master {
      }
    
      gestures {
      	workspace_swipe=yes
      	workspace_swipe_fingers=4
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
      bind=SUPER,E,exec,kitty --title kitty -e ranger
      bind=SUPER,S,togglefloating,
      bind=SUPER,F,fullscreen,
      bind=SUPER,space,exec,wofi --show drun -I -G -o DP-3 --width 30%
      bind=SUPER,P,pseudo,

      # special workspace
      bind=CTRL_SUPER,W,exec,hyprctl dispatch movetoworkspace special
      bind=SUPER,W,workspace,special
      bind=SHIFT_SUPER,W,exec, hyprctl dispatch togglespecialworkspace ""

      # screen locking
      bind=SUPER,L,exec,swaylock

      # clear notifications
      bind=SUPER,N,exec,makoctl dismiss --all

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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Using Bluetooth headset buttons to control media player
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [ "network.target" "sound.target" ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
