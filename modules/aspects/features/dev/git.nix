{den, ...}: {
  den.aspects.git = {
    homeManager = {config, ...}: let
      ud = config.my.userConfig;
    in {
      programs = {
        gitui.enable = true;
        delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            navigate = true;
            side-by-side = true;
            line-numbers = true;
            syntax-theme = "catppuccin-mocha";
            whitespace-error-style = "22 reverse";
          };
        };
        git = {
          enable = true;
          lfs.enable = true;
          userName = ud.git.user.name or "danielgafni";
          userEmail = ud.git.user.email or "danielgafni16@gmail.com";
          signing = {
            key = ud.git.signingkey or null;
            signByDefault = ud ? git.signingkey;
          };
          extraConfig = {
            push.autoSetupRemote = true;
            push.default = "current";
            fetch.prune = true;
            diff.colorMoved = "default";
            diff.algorithm = "histogram";
            merge.conflictstyle = "diff3";
            init.defaultBranch = "main";
            pull = {
              ff = "only";
              rebase = true;
            };
            rerere.enabled = true;
          };
        };
      };
    };
  };
}
