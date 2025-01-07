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
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    #ags.url = "github:Aylur/ags";
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

    zed = {
      # pinned specific tag
      url = "github:zed-industries/zed?ref=tags/v0.168.2";
    };

    sops-nix.url = "github:Mic92/sops-nix";
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
    zed,
    sops-nix,
    ...
  } @ inputs: let
    # helper variables and functions
    # used to produce the main configurations in the flake
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
        inputs.hyprpanel.overlay

        # https://github.com/Jas-SinghFSU/HyprPanel/issues/479
        # remove after inxpkgs update
        (final: prev: {
          matugen = final.rustPlatform.buildRustPackage rec {
            pname = "matugen";
            version = "2.4.0";

            src = final.fetchFromGitHub {
              owner = "InioX";
              repo = "matugen";
              rev = "refs/tags/v${version}";
              hash = "sha256-l623fIVhVCU/ylbBmohAtQNbK0YrWlEny0sC/vBJ+dU=";
            };

            cargoHash = "sha256-FwQhhwlldDskDzmIOxhwRuUv8NxXCxd3ZmOwqcuWz64=";

            meta = {
              description = "Material you color generation tool";
              homepage = "https://github.com/InioX/matugen";
              changelog = "https://github.com/InioX/matugen/blob/${src.rev}/CHANGELOG.md";
              license = final.lib.licenses.gpl2Only;
              maintainers = with final.lib.maintainers; [lampros];
              mainProgram = "matugen";
            };
          };
        })
      ];
    };

    system = "x86_64-linux";

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

    user-configs = {
      dan = rec {
        email = "danielgafni16@gmail.com";
        fullName = "Daniel Gafni";
        git = {
          userName = "danielgafni";
          userEmail = email;
          signingkey = "7B0740201D518DB134D5C75AB8D13360DED17662";
        };
      };
      underdel = {
        email = "linagafni@gmail.com";
        fullName = "Lina Gafni";
      };
    };

    host-users-map = {
      DanPC = ["dan"];
      framnix = ["dan" "underdel"];
    };

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
      "graphite-cli"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "whatsapp-for-linux"
    ];

    mkNixosConfiguration = {
      host,
      user-selection,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          # Pass flake inputs to our config
          inherit pkgs nixos-hardware allowed-unfree-packages inputs;
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
          hyprland.nixosModules.default
          catppuccin.nixosModules.catppuccin
          stylix.nixosModules.stylix
          {programs.hyprland.xwayland.enable = true;}
          sops-nix.nixosModules.sops
        ];
      };

    mkHomeConfiguration = {
      host,
      user,
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # pkgs = nixpkgs.legacyPackages."${system}"; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {
          # these args are passed to the other home-manager modules
          inherit allowed-unfree-packages user inputs home-manager catppuccin;
          host-settings = import ./hosts/${host}/settings.nix;
          userConfig = user-configs.${user};
        };
        # > Our main home-manager configuration file <
        modules = [
          ./home
          ./hosts/${host}/home

          catppuccin.homeManagerModules.catppuccin
          hyprland.homeManagerModules.default
          nixvim.homeManagerModules.nixvim
          {
            wayland.windowManager.hyprland.enable = true;
          }
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
    formatter."${system}" = nixpkgs.legacyPackages."${system}".alejandra;
    devShells."${system}".default = nixpkgs.legacyPackages."${system}".mkShell {
      inherit (self.checks."${system}".pre-commit-check) shellHook;
      buildINputs = self.checks."${system}".pre-commit-check.enabledPackages;
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
