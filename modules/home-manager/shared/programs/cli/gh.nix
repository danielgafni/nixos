_: {
  programs.gh-dash = {
    enable = true;
  };
  programs.gh = {
    enable = true;
    settings = {
      aliases = {};
      editor = "";
      git_protocol = "ssh";
    };
  };
}
