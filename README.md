# NixOS Config

My NixOS configuration featuring multi-host setup, a few GitHub Actions, remote caching, pre-commit hooks & CI, and [Catppuccin](https://catppuccin.com/) theme for all programs.


> [!WARNING]  
> WIP, not documented

Key specs:

- `home-manager` for user configuration
- `hyprland` as Wayland compositor & window manager
- `eww` for status bar and a few widgets
- `catppuccin` theme for everything

![assets/NixOS-rice.png](assets/NixOS-rice.png)


### Fonts

| Purpose | Name | Comment |
|----------|----------|-------|
| Code    | FiraCode Nerd Font | |
| UI    | Cabin   | Easy on eyes, good default |
| UI    | Recursive  | Eye candy, catchy |

## Usage

### Installation

prerequisites: `nix`

The repo contains a helper `justfile` to assist with common NixOS management tasks.
`just`, `unbuffer` (provided by `expect` package) and `nom` commands are required to use it. They can be installed with `Nix` in case they are missing:

```shell
nix-shell -p home-manager just expect nix-output-monitor
```

To test a new NixOS build, run:

```shell
just nixos-rebuild <host>
```

This will download, build and install **system** packages and configurations.

To make the build permanent, add `mode=switch`:

```shell
just mode=switch nixos-rebuild <host>
```

This will add a new boot record to the bootloader.

Files in `$HOME` are defined via `Home Manager`, which can be invoked separately:

```shell
just home <host> switch
```

## Installing on non-NixOS distros

Make sure to put 

```
extra-experimental-features = nix-command flakes
trusted-users = root @wheel dan
substituters = https://hyprland.cachix.org https://nixpkgs-wayland.cachix.org https://pre-commit-hooks.cachix.org https://nixpkgs-wayland.cachix.org
trusted-public-keys = hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= danielgafni.cachix.org-1:ZdXJoJEqeiGGOf/MtAiocqj7/vvFbA2MWFVwopJ2WQM=
auto-optimise-store = true
```

to `/etc/nix/nix.conf` before doing anything (otherwise your life will be miserable and you will be building packages from scratch for an eternity)

All of the `$HOME` directory configuration (installed packages, programs, and configs from `home` directory of this repo) from `home-manager` can be installed on a non-NixOS distro. However, system settings would have to be configured manually. Below is an incomplete set of isntructions for system configuration on other distros.

### ArchLinux

WIP

# Random Debugging Stuff

### mime-type

```shell
XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype foo.pdf

XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default application/pdf

fd evince.desktop /
```
