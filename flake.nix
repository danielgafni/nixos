{
  description = "@danielgafni's NixOS config";

  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";

    nixvim = {
      url = "github:nix-community/nixvim";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # provides catppuccin for lots of packages
    catppuccin.url = "github:catppuccin/nix";

    # stylix (currently only used for system theming like GRUB due to inflexibility)
    stylix.url = "github:danth/stylix";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # tmp fix for nvidia-docker until it's working in nixos-unstable
    nixpkgs-23_11.url = "github:nixos/nixpkgs/nixos-23.11";

    # chaotic provides a bunch of bleeding edge packages
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dagger = {
      url = "github:dagger/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";

    waystt = {
      url = "github:sevos/waystt";
      flake = false;
    };

    stax = {
      url = "github:cesarferreira/stax";
      flake = false;
    };

    rip.url = "github:cesarferreira/rip";

    # pinned nixpkgs for stable 1password-cli (2.33.1)
    nixpkgs-1password.url = "github:NixOS/nixpkgs/832efc09b4caf6b4569fbf9dc01bec3082a00611";

    # 1Password shell plugins
    _1password-shell-plugins.url = "github:1Password/shell-plugins";

    # macOS Spotlight integration for Nix apps
    mac-app-util.url = "github:hraban/mac-app-util";

    # nix-darwin (named 'darwin' for Den framework compatibility)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Den framework (Dendritic pattern)
    den.url = "github:vic/den";

    # Dendritic infrastructure
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    devenv.url = "github:cachix/devenv";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    (inputs.import-tree ./modules);
}
