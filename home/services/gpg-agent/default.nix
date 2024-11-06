{pkgs, ...}: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-curses;
    extraConfig = ''
      extra-socket /run/user/1001/gnupg/S.gpg-agent.extra
    '';
    #extraConfig = ''
    #  pinentry-mode loopback
    #  allow-loopback-pinentry
    #'';
  };
}
