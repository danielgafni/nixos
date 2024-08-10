<<<<<<< HEAD
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
||||||| parent of ec9c983 (:rocket: non-NixOS distros installation)
=======
{pkgs, ...}: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-curses;
    extraConfig = ''
      pinentry-mode loopback
      allow-loopback-pinentry
    '';
  };
}
>>>>>>> ec9c983 (:rocket: non-NixOS distros installation)
