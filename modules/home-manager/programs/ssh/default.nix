_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # devbox = {
      #   forwardAgent = true;
      #   hostname = "16.171.214.85";
      #   user = "dan";
      #   extraOptions = {
      #     RemoteForward = "/run/user/1001/gnupg/S.gpg-agent /run/user/1001/gnupg/S.gpg-agent.extra";
      #     #  "/run/user/1001/gnupg/S.gpg-agent.ssh /run/user/1001/gnupg/S.gpg-agent.ssh"
      #   };
      # };
      # skynet = {
      # forwardAgent = true;
      # hostname = "76.126.173.16";
      # user = "dan";
      # };
    };
  };
}
