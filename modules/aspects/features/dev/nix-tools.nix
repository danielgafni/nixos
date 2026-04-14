{den, ...}: {
  den.aspects = {
    nix-tools = {
      homeManager = {
        pkgs,
        lib,
        ...
      }: {
        programs.nix-index.enable = true;
        nix = {
          package = lib.mkDefault pkgs.nix;
          settings = {
            netrc-file = /etc/nix/.netrc;
            experimental-features = ["nix-command" "flakes"];
          };
        };
        home.packages = with pkgs; [nixd nil nh nvd alejandra];
      };
    };

    nix-tools-linux = {
      homeManager = _: {
        nix.settings.auto-optimise-store = true;
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
      };
    };
  };
}
