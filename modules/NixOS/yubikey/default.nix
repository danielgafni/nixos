{
  pkgs,
  lib,
  ...
}: {
  services = {
    udev.packages = [pkgs.yubikey-personalization];
    yubikey-agent.enable = false; # using gpg agent instead
  };
  programs.ssh.startAgent = false; # using gpg agent instead
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  # https://discourse.nixos.org/t/agenix-ragenix-issues-with-age-plugin-yubikey-and-the-mysterious-age-plugin-yubikey-resolves-to-executable-in-current-directory-error/46890/2?u=danielgafni
  age.ageBin = "PATH=$PATH:${lib.makeBinPath [pkgs.age-plugin-yubikey]} ${pkgs.rage}/bin/rage";
  # age.identityPaths = lib.mkOptionDefault ["${self}/secrets/ssh/age-yubikey-identity-<fill>.txt"];
  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      age-plugin-yubikey
      yubikey-personalization
      yubikey-personalization-gui
      yubikey-manager
      ragenix
      ;
  };
}
