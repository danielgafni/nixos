_: {
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    extraConfig = ''
      RemoteForward /run/user/1001/gnupg/S.gpg-agent /run/user/1001/gnupg/S.gpg-agent.extra
      RemoteForward /run/user/1001/gnupg/S.gpg-agent.ssh /run/user/1001/gnupg/S.gpg-agent.ssh
    '';
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
