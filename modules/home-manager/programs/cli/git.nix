{userConfig, ...}: {
  programs.gitui = {
    enable = true;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      whitespace-error-style = "22 reverse";
    };
  };

  programs.git =
    if builtins.hasAttr "git" userConfig
    then {
      enable = true;

      signing.key = userConfig.git.signingkey;

      settings = {
        inherit (userConfig.git) user;
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
