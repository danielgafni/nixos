{pkgs, ...}: {
  services = {
    udev.packages = [pkgs.yubikey-personalization];
    yubikey-agent.enable = false; # using gpg agent instead
  };
  programs.ssh.startAgent = false; # using gpg agent instead
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent updatestartuptty /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
