_: {
  programs.git = {
    enable = true;
    userName = "danielgafni";
    userEmail = "danielgafni16@gmail.com";
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        whitespace-error-style = "22 reverse";
      };
    };
    extraConfig = {
      commit.gpgsign = true;
      user.signingkey = "7B0740201D518DB134D5C75AB8D13360DED17662";
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
  };
}
