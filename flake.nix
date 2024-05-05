{
  description = "@danielgafni's NixOS config";

  inputs = {
    # Nixpkgs
    hyprland.url = "github:hyprwm/Hyprland";
    helix.url = "github:helix-editor/helix";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    # eww-wayland.url = "github:elkowar/eww";
    # tmp fix https://github.com/elkowar/eww/issues/817
    # eww-wayland.inputs.nixpkgs.follows = "nixpkgs-wayland";
    # eww-wayland.inputs.rust-overlay.follows = "rust-overlay";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

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
    hyprland,
    stylix,
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
        extraSpecialArgs = {inherit allowed-unfree-packages user inputs;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
          ./lib/default.nix
          ./home/default.nix

          # TODO: squash these 2 in 1 module
          ./hosts/framnix/home.nix
          ./hosts/framnix/default.nix

          hyprland.homeManagerModules.default
          {
            wayland.windowManager.hyprland.enable = true;
          }
        ];
      };

      "${user}@DanPC" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."${system}"; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit allowed-unfree-packages user inputs;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
          ./lib/default.nix
          ./home/default.nix

          # TODO: squash these 2 in 1 module
          ./hosts/DanPC/default.nix
          ./hosts/DanPC/home.nix

          hyprland.homeManagerModules.default
          {
            wayland.windowManager.hyprland.enable = true;
          }
        ];
      };
    };
  };
}
