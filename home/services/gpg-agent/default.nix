{pkgs, ...}: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-curses;
    #extraConfig = ''
    #  pinentry-mode loopback
    #  allow-loopback-pinentry
    #'';
  };
}
