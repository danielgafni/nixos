# NixOS Config

My NixOS configuration.

> [!WARNING]  
> WIP, not documented, perhaps not usable.

## Usage

### Installation
```shell
./install.sh # test mode by default - won't add a new bootloader entry
#or
./install.sh install  # add a bootloader entry to permanently save the new system
```

## Notes

### Fonds
 - Coding: `Fira Code Nerd Fonts`

### Debugging mime-type 

```shell
XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype foo.pdf

XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default application/pdf

fd evince.desktop /
```