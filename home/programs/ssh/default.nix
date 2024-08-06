_: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      devbox = {
        hostname = "16.171.214.85";
        user = "dan";
      };
      skynet = {
        hostname = "76.126.173.16";
        user = "dan";
      };
    };
  };
}
