{
  description = "@danielgafni's NixOS config";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # Desktop environment
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

    # Development
    rust-overlay.url = "github:oxalica/rust-overlay";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    zed = {
      url = "github:jcdickinson/zed?rev=f38dc6ceca39fb0e255b2e391ba52da453e26048";
    };

    # Home Manager & Theming
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    stylix.url = "github:danth/stylix";
    nixvim = {
      url = "github:nix-community/nixvim";
    };

    # Temporary fixes
    nixpkgs-23_11.url = "github:nixos/nixpkgs/nixos-23.11";
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
    };
  in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        allowUnfreePredicate = pkg:
          builtins.elem (lib.getName pkg) [
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
            "cursor"
          ];
      };

      snowfall = {
        namespace = "danielgafni";
        meta = {
          name = "nixos-config";
          title = "Daniel's NixOS Configuration";
        };
      };

      # Add formatter configuration
      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.alejandra;

      overlays = with inputs; [
        nixpkgs-wayland.overlay
        hyprpanel.overlay
        rust-overlay.overlays.default
      ];

      systems = [
        "x86_64-linux"
      ];

      # Snowfall will automatically discover modules
      modules.nixos = {
        yubikey = ./modules/NixOS/yubikey;
      };

      # Host configurations
      hosts = {
        DanPC = {
          system = "x86_64-linux";
          modules = with inputs; [
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-cpu-amd
            sops-nix.nixosModules.sops
          ];
        };
        framnix = {
          system = "x86_64-linux";
          modules = with inputs; [
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-cpu-intel
            sops-nix.nixosModules.sops
          ];
        };
      };

      # Home-manager configurations
      homes = {
        modules = with inputs; [
          hyprland.homeManagerModules.default
          nixvim.homeManagerModules.nixvim
        ];
      };

      checks =
        builtins.mapAttrs
        (system: _: {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              statix.enable = true;
            };
          };
        })
        lib.systems;
    };
}
