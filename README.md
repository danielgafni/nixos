# NixOS Config

My NixOS configuration with multi-host setup, a few GitHub Actions, [personal build cache](https://danielgafni.cachix.org/), checks via pre-commit hooks & CI, and [Catppuccin](https://catppuccin.com/) theme for all programs.

Key components:
- [NixOS](https://nixos.org/) for system configuration
- [Home Manager](https://github.com/nix-community/home-manager) for user configuration. Most user-space programs are installed and configured via Home Manager.
- [Hyprland](https://hyprland.org/) as Wayland compositor & window manager. It's very fast, looks amazing, and has a lot of features. Now has a huge community and is finally stable!
- [Hyprpanel](https://hyprpanel.com/) a panel, widgets, and notifications for Hyprland. Has very good defaults and doesn't require much configuration.
- [Ghostty](https://mitchellh.com/ghostty) - an amazing modern terminal emulator. Very performant, has a lot of features and super good defaults.
- [Catppuccin](https://catppuccin.com/) theme for everything - because it's beautiful, easy on eyes, and has an implementation for every app in the world. It's automatically applied to all programs via [cattppuccin/nix](https://github.com/catppuccin/nix).

![assets/NixOS-rice.png](assets/NixOS-rice.png)

Minor stuff:

- [Starship](https://starship.rs/) terminal prompt. Nothing can beat it in terms of speed, features, and looks.
- [YubiKey](https://www.yubico.com/) for SSH and GPG. It makes life easier and more secure.
- [Zed](https://github.com/zed-industries/zed) editor setup with a bunch of language servers and plugins. Zed is the future. The GOAT Python LSs are configured for Zed: `ruff` and `basedpyright`.

Packages are cached in CI so local installations are faster (this is critical for nightly Zed builds from the flake which take 40+ min).

## Usage

### Prerequisites


- [NixOS](https://nixos.org/download/) or just [nix](https://nix.dev/install-nix.html) (only `$HOME` setup)
- [nh](https://github.com/viperML/nh) - an excellent Nix helper. It has a better UX and the output is nicer. 

### Installation

```shell
nh os switch
```

This will download, build and install **system** packages, files and configurations.

> [!NOTE]
> Use `nh os test` to test configurations without adding boot entries.


```shell
nh home switch
```

This will download, build and install **user** packages, files and configurations.


## Notes

### Fonts

| Purpose | Name | Comment |
|----------|----------|-------|
| Code    | FiraCode Nerd Font | |
| UI    | Cabin   | Easy on eyes, good default |
| UI    | Recursive  | Eye candy, catchy |

It's necessary to rebuild fonts cache in order to observe live changes after modifying the config:

```shell
fc-cache -rf
```

### Custom modules

- `modules/` contains some custom modules. They are:

- `modules/home-manager/nebius-cli.nix` - [Nebius CLI](https://docs.nebius.com/cli)

### Debugging mime-type

```shell
XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype foo.pdf

XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default application/pdf

fd evince.desktop /
```
