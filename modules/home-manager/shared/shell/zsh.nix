{config, ...}: {
  programs.zsh = {
    enable = true;
    #zprof.enable = true;  # enable to profile zsh startup
    autosuggestion.enable = true;
    autocd = false; # using zoxide instead
    dirHashes = {
      dl = "$HOME/Downloads";
      docs = "$HOME/Documents";
      code = "$HOME/Documents/code";
      dots = "$HOME/Documents/code/dotfiles";
      pics = "$HOME/Pictures";
      vids = "$HOME/Videos";
      nixpkgs = "$HOME/Documents/code/git/nixpkgs";
    };
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      expireDuplicatesFirst = true;
      path = "${config.xdg.dataHome}/zsh_history";
      size = 100000;
      save = 100000;
    };

    initContent = builtins.readFile ./.zshrc;

    shellAliases = {
      grep = "grep --color";
      ip = "ip --color";
      l = "eza -l";
      la = "eza -la";
      md = "mkdir -p";
      cd = "z";
      k = "kubectl";
      zj = "zellij";
      devbox-start = "aws ec2 start-instances --instance-ids i-04faa7b6877e3da94 --region eu-north-1";
      devbox-stop = "aws ec2 stop-instances --instance-ids i-04faa7b6877e3da94 --region eu-north-1";
      hyprlock-restart = "hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1' && hyprctl --instance 0 'dispatch exec hyprlock'";
      hyprland-logs-tty = "cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log";
      hyprland-logs = "cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 2 | tail -n 1)/hyprland.log";
    };
    shellGlobalAliases = {
      eza = "eza --icons --git";
    };
    zplug = {
      enable = true;
      plugins = [
        {name = "zdharma-continuum/fast-syntax-highlighting";}
        {
          name = "chisui/zsh-nix-shell";
          tags = ["lazy:true"];
        }
      ];
    };
  };
}
