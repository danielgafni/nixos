{
  description = "@danielgafni's NixOS config";

  inputs = {
    # Nixpkgs
    hyprland.url = "github:hyprwm/Hyprland?rev=fe7b748eb668136dd0558b7c8279bfcd7ab4d759"; # v0.39.1
    helix.url = "github:helix-editor/helix";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # eww-wayland.url = "github:elkowar/eww";
    # tmp fix https://github.com/elkowar/eww/issues/817
    # eww-wayland.inputs.nixpkgs.follows = "nixpkgs-wayland";
    # eww-wayland.inputs.rust-overlay.follows = "rust-overlay";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # provides catppuccin for lots of packages
    catppuccin.url = "github:catppuccin/nix";

    # nixify themex and make everything match nicely with nix-colors!
    nix-colors.url = "github:misterio77/nix-colors";

    # stylix (currently only used for system theminx liks GRUB due to inflexibility)
    stylix.url = "github:danth/stylix";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    home-manager,
    catppuccin,
    hyprland,
    stylix,
    nixvim,
    ...
  } @ inputs: {
    checks.x86_64-linux = {
      pre-commit-check = pre-commit-hooks.lib."x86_64-linux".run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          # TODO: enable # statix.enable = true;
        };
      };
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
      buildINputs = self.checks.x86_64-linux.pre-commit-check.enabledPackages;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      framnix = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;}; # Pass flake inputs to our config
        # > Our main nixos configuration file <
        modules = [
          ./hosts/framnix/configuration.nix
          hyprland.nixosModules.default
          catppuccin.nixosModules.catppuccin
          stylix.nixosModules.stylix
          {programs.hyprland.xwayland.enable = true;}
        ];
      };

      DanPC = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;}; # Pass flake inputs to our config
        # > Our main nixos configuration file <
        modules = [
          ./hosts/DanPC/configuration.nix
          hyprland.nixosModules.default
          catppuccin.nixosModules.catppuccin
          stylix.nixosModules.stylix
          {programs.hyprland.xwayland.enable = true;}
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "dan@framnix" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs home-manager;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
          ./lib/default.nix
          ./home/default.nix

          # TODO: squash these 2 in 1 module
          ./hosts/framnix/home.nix
          ./hosts/framnix/default.nix

          catppuccin.homeManagerModules.catppuccin
          hyprland.homeManagerModules.default
          {
            wayland.windowManager.hyprland.enable = true;
          }
        ];
      };

      "dan@DanPC" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
          ./lib/default.nix
          ./home/default.nix

          # TODO: squash these 2 in 1 module
          ./hosts/DanPC/default.nix
          ./hosts/DanPC/home.nix

          catppuccin.homeManagerModules.catppuccin
          hyprland.homeManagerModules.default
          {
            wayland.windowManager.hyprland.enable = true;
          }
        ];
      };
    };
  };
}
