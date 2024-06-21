_: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      devbox = {
        hostname = "64.176.70.67";
        user = "root";
      };
    };
  };
}
