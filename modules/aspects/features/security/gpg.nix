{den, ...}: {
  den.aspects = {
    gpg = {
      homeManager = {lib, ...}: {
        programs.gpg = {
          enable = true;
          publicKeys = [
            {
              source = ./data/yubikey.pgp;
              trust = 5;
            }
            {
              source = ./data/yubikey-old.pgp;
              trust = 5;
            }
          ];
        };
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
          enableExtraSocket = true;
          defaultCacheTtl = 7200;
          maxCacheTtl = 7200;
          defaultCacheTtlSsh = 7200;
          maxCacheTtlSsh = 7200;
          extraConfig = ''allow-loopback-pinentry'';
        };
        # Ensure GPG agent is used for SSH and TTY is set correctly
        programs.zsh.initContent = lib.mkOrder 500 ''
          export GPG_TTY="$(tty)"
          gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
        '';
      };
    };
    gpg-darwin = {
      homeManager = {
        pkgs,
        lib,
        ...
      }: {
        services.gpg-agent.pinentry.package = lib.mkForce pkgs.pinentry_mac;
      };
    };
    gpg-linux = {
      homeManager = {
        pkgs,
        lib,
        ...
      }: {
        services.gpg-agent = {
          pinentry.package = lib.mkForce pkgs.pinentry-gtk2;
        };
      };
    };
  };
}
