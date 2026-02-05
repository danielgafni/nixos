{config, ...}: {
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };

      git_status = {
        deleted = "✗";
        modified = "✶";
        staged = "✓";
        stashed = "≡";
      };

      nix_shell = {
        symbol = " ";
        heuristic = true;
      };

      kubernetes = {
        disabled = true;
        symbol = "☸ ";
      };

      aws = {
        symbol = "🅰 ";
      };

      gcloud = {
        disabled = true;
        symbol = "🇬️";
      };

      custom.github_pr = {
        command = ''
          cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/starship"
          repo_id=$(git rev-parse --show-toplevel 2>/dev/null | md5sum | cut -c1-8)
          cache_file="$cache_dir/gh_pr_$repo_id"
          [ -f "$cache_file" ] && cat "$cache_file"
        '';
        when = "git rev-parse --git-dir 2>/dev/null";
        format = "[$output]($style) ";
        style = "cyan";
        shell = ["bash" "--noprofile" "--norc"];
      };
    };
  };
}
