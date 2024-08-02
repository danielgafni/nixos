_: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      devbox = {
        hostname = "64.176.70.67";
        user = "root";
      };
      skynet = {
        hostname = "76.126.173.16";
        user = "dan";
      };
    };
  };
}
