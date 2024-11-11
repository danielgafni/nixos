{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
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
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      path = "${config.xdg.dataHome}/zsh_history";
    };

    initExtra = builtins.readFile ./.zshrc;

    shellAliases = {
      grep = "grep --color";
      ip = "ip --color";
      l = "eza -l";
      la = "eza -la";
      md = "mkdir -p";
      cd = "z";
    };
    shellGlobalAliases = {eza = "eza --icons --git";};
    zplug = {
      enable = true;
      plugins = [
        {name = "zdharma-continuum/fast-syntax-highlighting";}
      ];
    };
  };
}
