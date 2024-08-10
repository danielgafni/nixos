{
  lib,
  pkgs,
  allowed-unfree-packages,
  ...
}: {
  nix = {
    package = pkgs.nix;
    settings = {
      netrc-file = /etc/nix/.netrc; # for credentials (like pribate PyPI server)
      trusted-users = ["root" "dan"];
      substituters = [
        "https://hyprland.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://pre-commit-hooks.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "danielgafni.cachix.org-1:ZdXJoJEqeiGGOf/MtAiocqj7/vvFbA2MWFVwopJ2WQM="
      ];
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed-unfree-packages;
  };
}
