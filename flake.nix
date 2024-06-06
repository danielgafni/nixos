{
  description = "@danielgafni's NixOS config";

  inputs = {
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    helix.url = "github:helix-editor/helix";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";

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
    hyprland-plugins,
    stylix,
    nixvim,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    user = "dan";

    # Define the list of unfree packages to allow here, so you can pass it to
    # both `sudo nixos-rebuild` and `home-manager`
    allowed-unfree-packages = [
      "google-chrome"
      "obsidian"
      "postman"
      "vscode"
      "vscode-extension-github-copilot"
      "lens-desktop"
      "slack"
      "discord"
      "pycharm-professional"
      "gateway"
    ];
  in {
    checks."${system}" = {
      pre-commit-check = pre-commit-hooks.lib."${system}".run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          # TODO: enable # statix.enable = true;
        };
      };
    };

    formatter."${system}" = nixpkgs.legacyPackages."${system}".alejandra;
    devShells."${system}".default = nixpkgs.legacyPackages."${system}".mkShell {
      inherit (self.checks."${system}".pre-commit-check) shellHook;
      buildINputs = self.checks."${system}".pre-commit-check.enabledPackages;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      framnix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit allowed-unfree-packages user inputs;}; # Pass flake inputs to our config
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
        inherit system;
        specialArgs = {inherit allowed-unfree-packages user inputs;}; # Pass flake inputs to our config
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
      "${user}@framnix" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."${system}"; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit allowed-unfree-packages user inputs home-manager;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
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

      "${user}@DanPC" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."${system}"; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit allowed-unfree-packages user inputs home-manager;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
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
