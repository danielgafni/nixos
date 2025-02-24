{pkgs, ...}: {
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs = {
    nix-index.enable = true;
  };

  nix = {
    package = pkgs.nix;
    settings = {
      netrc-file = /etc/nix/.netrc; # for credentials (like pribate PyPI server)
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  home.packages = with pkgs; [
    # Nix related packages
    nixd
    nil
    nh
    nvd
    alejandra
  ];
}
