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
        disabled = false;
        symbol = "☸ ";
      };

      aws = {
        symbol = "🅰 ";
      };

      gcloud = {
        disabled = true;
        symbol = "🇬️";
      };
    };
  };
}
