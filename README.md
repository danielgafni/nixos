# NixOS Config

My NixOS configuration.

> [!WARNING]  
> WIP, not documented, perhaps not usable.

## Usage

### Installation

prerequisites: `nix` 

```shell
nix-shell -p just
just nixos-rebuild <host>  # add mode=switch, default mode is test
just home DanPC switch  # invoke home-manager to create files in $HOME
```

## Notes

### Fonts
 - Coding: `Fira Code Nerd Fonts`

### Debugging mime-type 

```shell
XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype foo.pdf

XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default application/pdf

fd evince.desktop /
```
