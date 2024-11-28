{
  pkgs,
  lib,
  ...
}: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryPackage = lib.mkForce pkgs.pinentry-gtk2;
    extraConfig = ''
      extra-socket /run/user/1001/gnupg/S.gpg-agent.extra
      #pinentry-mode loopback
      allow-loopback-pinentry
    '';
  };
}
