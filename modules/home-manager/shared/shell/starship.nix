{config, ...}: let
  ghPrCachePath = import ./gh-pr-cache.nix;
in {
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
        command =
          ghPrCachePath
          + ''
            [ -f "$cache_file" ] && cat "$cache_file"
          '';
        when = "git rev-parse --git-dir 2>/dev/null";
        format = "$output ";
        shell = ["bash" "--noprofile" "--norc"];
      };
    };
  };
}
