{
  description = "@danielgafni's NixOS config";

  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";

    nixvim = {
      url = "github:nix-community/nixvim";
      # inputs.nixpkgs.follows = "nixpkgs";
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

    zed = {
      # I'm forking Zed until https://github.com/zed-industries/zed/issues/22098 is resolved
      url = "github:danielgafni/zed";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    dagger = {
      url = "github:dagger/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    pre-commit-hooks,
    home-manager,
    catppuccin,
    hyprland,
    hyprland-plugins,
    hyprpanel,
    stylix,
    nixvim,
    sops-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        inputs.nixpkgs-wayland.overlay
        inputs.hyprpanel.overlay
      ];
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    users = {
      dan = {
        isNormalUser = true;
        initialPassword = "pw123";
        extraGroups = ["wheel" "docker" "video" "networkmanager"];
        packages = [pkgs.home-manager];
      };
      underdel = {
        isNormalUser = true;
        initialPassword = "pw123";
        extraGroups = ["video" "networkmanager"];
        packages = [pkgs.home-manager];
      };
    };

    # todo: move this to users/
    user-configs = {
      dan = rec {
        email = "danielgafni16@gmail.com";
        fullName = "Daniel Gafni";
        git = {
          userName = "danielgafni";
          userEmail = email;
          signingkey = "7B0740201D518DB134D5C75AB8D13360DED17662";
        };
        hyprland.autostart = with pkgs; [
          {
            workspace = "2";
            program = "${slack}/bin/slack";
          }
          {
            workspace = "2";
            program = "${discord}/bin/discord";
          }
          {
            workspace = "2";
            program = "${telegram-desktop}/bin/telegram-desktop";
          }
          {
            workspace = "1";
            program = "${google-chrome}/bin/google-chrome-stable";
          }
          {
            workspace = "3";
            program = "zed";
          }
        ];
      };
      underdel = {
        email = "linagafni@gmail.com";
        fullName = "Lina Gafni";
        hyprland.autostart = [];
      };
    };

    host-users-map = {
      DanPC = ["dan"];
      framnix = ["dan" "underdel"];
    };

    mkNixosConfiguration = {
      host,
      user-selection,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = {
          # Pass flake inputs to our config
          inherit nixos-hardware inputs;
          users = {
            extraGroups.docker.members = ["dan"];
            defaultUserShell = pkgs.zsh;
            # subset of users by user-selection
            users = nixpkgs.lib.filterAttrs (name: user: builtins.elem name user-selection) users;
          };
        };
        modules = [
          ./hosts/configuration.nix
          ./hosts/${host}/NixOS
          # hyprland.nixosModules.default
          catppuccin.nixosModules.catppuccin
          stylix.nixosModules.stylix
          {programs.hyprland.xwayland.enable = true;}
          sops-nix.nixosModules.sops
        ];
      };

    # helli world

    mkHomeConfiguration = {
      host,
      user,
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          # these args are passed to the other home-manager modules
          inherit user inputs;
          host-settings = import ./hosts/${host}/settings.nix;
          userConfig = user-configs.${user};
        };
        # > Our main home-manager configuration file <
        modules = [
          ./home
          ./hosts/${host}/home
          catppuccin.homeManagerModules.catppuccin
          nixvim.homeManagerModules.nixvim
          sops-nix.homeManagerModules.sops
        ];
      };
  in {
    # actual flake outputs

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
    formatter."${system}" = pkgs.alejandra;
    devShells."${system}".default = pkgs.mkShell {
      inherit (self.checks."${system}".pre-commit-check) shellHook;
      buildInputs = self.checks."${system}".pre-commit-check.enabledPackages;
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#<hostname>' (hosts are taken from the 'hosts' list above)
    nixosConfigurations =
      nixpkgs.lib.attrsets.mapAttrs (host: user-selection: mkNixosConfiguration {inherit host user-selection;})
      host-users-map;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#<user>@<hostname>'

    homeConfigurations =
      pkgs.lib.concatMapAttrs (
        host: users:
          pkgs.lib.listToAttrs (pkgs.lib.map (user: {
              name = "${user}@${host}";
              value = mkHomeConfiguration {inherit host user;};
            })
            users)
      )
      host-users-map;
  };
}
