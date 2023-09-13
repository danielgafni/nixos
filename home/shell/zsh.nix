{ config
, pkgs
, lib
, ...
}: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    autocd = true;
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

    initExtra = (builtins.readFile ./.zshrc);

    shellAliases = {
      grep = "grep --color";
      ip = "ip --color";
      l = "exa -l";
      la = "exa -la";
      md = "mkdir -p";
    };
    shellGlobalAliases = { exa = "exa --icons --git"; };
    zplug = {
      enable = true;
      plugins = [
        { name = "zdharma-continuum/fast-syntax-highlighting"; }
      ];
    };
  };
}
