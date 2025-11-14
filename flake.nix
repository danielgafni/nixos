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
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # provides catppuccin for lots of packages
    catppuccin.url = "github:catppuccin/nix";

    # stylix (currently only used for system theminx liks GRUB due to inflexibility)
    stylix.url = "github:danth/stylix";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # tmp fix for nvidia-docker until it's working in nixos-unstable
    nixpkgs-23_11.url = "github:nixos/nixpkgs/nixos-23.11";

    #zed = {
    #  url = "github:zed-industries/zed";
    #};

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

    # nixpkgs-vsCodeExtensionsPythonPinned = {
    #   url = "github:NixOs/nixpkgs?rev=2d068ae5c6516b2d04562de50a58c682540de9bf";
    # };

    vicinae.url = "github:vicinaehq/vicinae";

    krewfile = {
      url = "github:brumhard/krewfile";
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
    stylix,
    nixvim,
    sops-nix,
    # nixpkgs-zed,
    chaotic,
    vicinae,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = [
      inputs.nixpkgs-wayland.overlay
    ];

    pkgs = import nixpkgs {
      inherit system overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    # vsCodeExtensionsPythonPinnedPkgs = import inputs.nixpkgs-vsCodeExtensionsPythonPinned {
    #   inherit system;
    # };

    # zedNixPkgs = import inputs.nixpkgs-zed {
    #   inherit system;
    # };

    users = {
      dan = {
        isNormalUser = true;
        initialPassword = "pw123";
        extraGroups = [
          "wheel"
          "docker"
          "video"
          "networkmanager"
        ];
        packages = [pkgs.home-manager];
      };
      underdel = {
        isNormalUser = true;
        initialPassword = "pw123";
        extraGroups = [
          "video"
          "networkmanager"
        ];
        packages = [pkgs.home-manager];
      };
    };

    # todo: move this to homes/
    user-configs = {
      dan = rec {
        email = "danielgafni16@gmail.com";
        fullName = "Daniel Gafni";
        git = {
          userName = "danielgafni";
          userEmail = email;
          signingkey = "2DD3012F76C19D80";
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
            program = "zeditor";
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
      framnix = [
        "dan"
        "underdel"
      ];
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
          ./modules/NixOS/shared
          ./systems/x86_64-linux/${host}
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
          inherit user inputs; # zedNixpkgs
          host-settings = import ./modules/settings/${host};
          userConfig = user-configs.${user};
        };
        modules = [
          ./homes/${user}
          ./modules/home-manager/hosts/${host}
          ./modules/home-manager/shared
          catppuccin.homeModules.catppuccin
          nixvim.homeModules.nixvim
          sops-nix.homeManagerModules.sops
          vicinae.homeManagerModules.default
          stylix.homeModules.stylix
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
      nixpkgs.lib.attrsets.mapAttrs (
        host: user-selection: mkNixosConfiguration {inherit host user-selection;}
      )
      host-users-map;

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#<user>@<hostname>'

    homeConfigurations =
      pkgs.lib.concatMapAttrs (
        host: users:
          pkgs.lib.listToAttrs (
            pkgs.lib.map (user: {
              name = "${user}@${host}";
              value = mkHomeConfiguration {inherit host user;};
            })
            users
          )
      )
      host-users-map;
  };
}
