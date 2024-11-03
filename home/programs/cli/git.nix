{
  lib,
  user,
  userConfig,
  ...
}: {
  programs.git =
    if builtins.hasAttr "git" userConfig
    then {
      enable = true;
      inherit (userConfig.git) userName userEmail;
      signing.key = userConfig.git.signingkey;
      delta = {
        enable = true;
        options = {
          side-by-side = true;
          whitespace-error-style = "22 reverse";
        };
      };
      extraConfig = {
        commit.gpgsign = true;
        # the below options are mostly taken from https://jvns.ca/blog/2024/02/16/popular-git-config-options/
        push.autosetupremote = true;
        push.default = "current";
        pull.rebase = true;
        fetch.prune = true;
        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
        rerere.enabled = true;
        diff.algorithm = "histogram";
      };
    }
    else {
      enable = false;
    };
}
