_: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      devbox = {
        hostname = "16.171.214.85";
        user = "dan";
        #        RemoteForward = "/run/user/1000/gnupg/S.gpg-agent /run/user/1001/gnupg/S.gpg-agent.extra";
      };
      skynet = {
        hostname = "76.126.173.16";
        user = "dan";
      };
    };
  };
}
