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
          signing = {
            key = ud.git.signingkey or null;
            signByDefault = ud ? git.signingkey;
          };
          settings = {
            user = {
              name = ud.git.user.name or "danielgafni";
              email = ud.git.user.email or "danielgafni16@gmail.com";
            };
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
            blame.ignoreRevsFile = ".git-blame-ignore-revs";
          };
        };
      };
    };
  };
}
