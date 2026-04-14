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

      services.skhd = {
        enable = true;
        skhdConfig = ''
          alt - return : open -a Ghostty

          # Switch desktops (requires Mission Control shortcuts enabled in System Settings)
          alt - 1 : osascript -e 'tell application "System Events" to key code 18 using control down'
          alt - 2 : osascript -e 'tell application "System Events" to key code 19 using control down'
          alt - 3 : osascript -e 'tell application "System Events" to key code 20 using control down'
          alt - 4 : osascript -e 'tell application "System Events" to key code 21 using control down'
          alt - 5 : osascript -e 'tell application "System Events" to key code 23 using control down'
          alt - 6 : osascript -e 'tell application "System Events" to key code 22 using control down'

          # Fullscreen toggle
          alt - f : osascript -e 'tell application "System Events" to keystroke "f" using {control down, command down}'
        '';
      };
    };
  };
}
