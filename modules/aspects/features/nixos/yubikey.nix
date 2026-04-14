_: {
  den.aspects.yubikey = {
    nixos = {pkgs, ...}: {
      services = {
        udev.packages = [pkgs.yubikey-personalization];
        yubikey-agent.enable = false;
      };
      programs.ssh.startAgent = false;
      environment.shellInit = ''
        export GPG_TTY="$(tty)"
        gpg-connect-agent updatestartuptty /bye
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      '';
    };
    homeManager = {
      lib,
      pkgs,
      ...
    }: {
      programs.zsh.initContent = lib.mkOrder 501 ''
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      '';
    };
  };
}
