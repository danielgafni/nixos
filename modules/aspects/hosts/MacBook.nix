{
  den,
  inputs,
  ...
}: {
  den.aspects.MacBook = {
    includes = [
      den.provides.hostname
      den.aspects.mac-app-util
      den.aspects.docker-mac
    ];
    darwin = {pkgs, ...}: {
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      system = {
        stateVersion = 6;
        primaryUser = "dan";
      };

      programs.zsh.enable = true;

      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["root" "dan" "@admin"];
        substituters = [
          "https://devenv.cachix.org"
        ];
        trusted-public-keys = [
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
      };

      # Touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      system.defaults = {
        dock = {
          autohide = true;
          autohide-delay = 3.0;
          # autohide-time-modifier = 0.0;
        };
        # NSGlobalDomain._HIHideMenuBar = true;
      };
    };
  };
}
