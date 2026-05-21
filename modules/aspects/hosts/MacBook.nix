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
          "https://zed.cachix.org"
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };

      # Touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # Cache sudo authentication for 30 minutes per tty (default is short).
      security.sudo.extraConfig = ''
        Defaults timestamp_timeout=30
      '';

      system.defaults = {
        dock = {
          autohide = true;
          autohide-delay = 3.0;
        };
        # NSGlobalDomain._HIHideMenuBar = true;
      };
    };
  };
}
