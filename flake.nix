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
    ags.url = "github:Aylur/ags";
    helix.url = "github:helix-editor/helix";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";

    nixvim = {
      url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # provides catppuccin for lots of packages
    catppuccin.url = "github:catppuccin/nix";

    # stylix (currently only used for system theminx liks GRUB due to inflexibility)
    stylix.url = "github:danth/stylix";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # tmp fix for nvidia-docker until it's working in nixos-unstable
    nixpkgs-23_11.url = "github:nixos/nixpkgs/nixos-23.11";
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
    # helper variables and functions
    # used to produce the main configurations in the flake
    system = "x86_64-linux";
    user = "dan";
    hosts = ["DanPC" "framnix"];

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
      "pycharm-professional-with-plugins"
      "gateway"
      "copilot.vim"
    ];

    pkgs-23_11 = import inputs.nixpkgs-23_11 {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowed-unfree-packages;
      };
    };

    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) allowed-unfree-packages;
      };
      overlays = [
        (final: prev: {
          inherit (pkgs-23_11.nvidia-docker);
        })
      ];
    };

    mkNixosConfiguration = host:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit pkgs allowed-unfree-packages user inputs;}; # Pass flake inputs to our config
        # > Our main nixos configuration file <
        modules = [
          ./hosts/configuration.nix
          ./hosts/${host}/NixOS
          hyprland.nixosModules.default
          catppuccin.nixosModules.catppuccin
          stylix.nixosModules.stylix
          {programs.hyprland.xwayland.enable = true;}
        ];
      };

    mkHomeConfiguration = host:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # pkgs = nixpkgs.legacyPackages."${system}"; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          # these args are passed to the other home-manager modules
          inherit allowed-unfree-packages user inputs home-manager catppuccin;
          host-settings = import ./hosts/${host}/settings.nix;
        };
        # > Our main home-manager configuration file <
        modules = [
          ./home
          ./hosts/${host}/home

          catppuccin.homeManagerModules.catppuccin
          hyprland.homeManagerModules.default
          {
            wayland.windowManager.hyprland.enable = true;
          }
        ];
      };
  in {
    # actual configurations

    # supporting configurations for development of this flake
    checks."${system}" = {
      pre-commit-check = pre-commit-hooks.lib."${system}".run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          statix.enable = true;
        };
      };
    };
    formatter."${system}" = nixpkgs.legacyPackages."${system}".alejandra;
    devShells."${system}".default = nixpkgs.legacyPackages."${system}".mkShell {
      inherit (self.checks."${system}".pre-commit-check) shellHook;
      buildINputs = self.checks."${system}".pre-commit-check.enabledPackages;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#<hostname>' (hosts are taken from the 'hosts' list above)
    nixosConfigurations = builtins.listToAttrs (map (host: {
        name = host;
        value = mkNixosConfiguration host;
      })
      hosts);

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#<user>@<hostname>' (hosts are taken from the 'hosts' list above)

    homeConfigurations = builtins.listToAttrs (map (host: {
        name = "${user}@${host}";
        value = mkHomeConfiguration host;
      })
      hosts);
  };
}
