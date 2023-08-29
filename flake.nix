{
  description = "@danielgafni's Framework 13 NixOS config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    helix.url = "github:helix-editor/helix";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { nixpkgs, home-manager, hyprland, ... }@inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # FIXME replace with your hostname
      framnix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        # > Our main nixos configuration file <
        modules = [
	  ./nixos/configuration.nix
	  hyprland.nixosModules.default
	  {programs.hyprland.enable = true;}
	  ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "dan@framnix" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [ 
	  ./lib/default.nix
	  ./home/default.nix
	  hyprland.homeManagerModules.default
	  {wayland.windowManager.hyprland.enable = true;}
	  ];
      };
    };
  };
}
