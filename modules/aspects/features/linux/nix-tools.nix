_: {
  den.aspects.nix-tools-linux = {
    homeManager = _: {
      nix.settings.auto-optimise-store = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
  };
}
