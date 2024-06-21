{pkgs, ...}: {
  services = {
    udev.packages = [pkgs.yubikey-personalization];
    yubikey-agent.enable = false; # using gpg agent instead
  };
  programs.ssh.startAgent = false; # using gpg agent instead
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
