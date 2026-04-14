{den, ...}: {
  den.aspects.cli = {
    homeManager = {
      config,
      pkgs,
      ...
    }: let
      ud = config.my.userConfig;
    in {
      programs = {
        bat = {
          enable = true;
          config.pager = "less -FR";
          extraPackages = with pkgs.bat-extras; [batdiff batman batgrep batwatch];
        };
        yazi = {
          enable = true;
          enableZshIntegration = true;
          shellWrapperName = "y";
        };
        zellij = {
          enable = true;
          enableBashIntegration = false;
          enableZshIntegration = false;
        };
        zoxide = {
          enable = true;
          enableZshIntegration = true;
        };
        gh = {
          enable = true;
          settings = {
            git_protocol = "ssh";
          };
        };
        gh-dash = {
          enable = true;
        };
        k9s = {
          enable = true;
        };
        rbw = {
          enable = true;
          settings = {
            email = ud.email or "danielgafni16@gmail.com";
          };
        };
      };
    };
  };
}
