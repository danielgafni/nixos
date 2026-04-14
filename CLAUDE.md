# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is a NixOS + nix-darwin + Home Manager flake. Use `nh` to build and switch:

```bash
nh os switch .      # NixOS hosts
nh darwin switch .  # macOS (MacBook)
nh home switch .    # Standalone home-manager profiles
```

use `--dry` to preview changes without applying them.

Other useful commands:

```bash
nix fmt                    # Format all Nix files (alejandra)
nix flake check            # Run all checks (includes pre-commit: alejandra + statix)
nil diagnostics <file>     # LSP diagnostics for a single file
statix check <file>        # Lint a single file (W20 is disabled in statix.toml)
```

## Architecture

This repo uses the **Dendritic Nix pattern** with the **Den framework**. Every file under `modules/` is a top-level flake-parts module, auto-imported via `import-tree`.

### Entry point

`flake.nix` evaluates `(import-tree ./modules)` through `flake-parts.lib.mkFlake`.

### Key modules

- **`modules/den.nix`** - Host/home/user declarations and per-host data lookup tables (monitors, scaling, fonts, keybindings). This is the central schema definition.
- **`modules/dev.nix`** - Dev shell, formatter, pre-commit hooks.
- **`modules/systems.nix`** - `x86_64-linux` and `aarch64-darwin`.

### Aspects (`modules/aspects/`)

Configuration is organized by **concern**, not by host. Each aspect is an attrset with class keys (`nixos`, `darwin`, `homeManager`, `user`). Parametric dispatch via function signatures replaces `mkIf`:

- `{ host, ... }: { ... }` - runs only in host context
- `{ host, user, ... }: { ... }` - runs only in host+user context
- `{ home, ... }: { ... }` - runs only for standalone homes

Three subdirectories:
- **`features/`** - Reusable concerns (editors, desktop, CLI tools, theming, platform services)
- **`hosts/`** - Per-host aspects (`DanPC.nix`, `framnix.nix`, `MacBook.nix`) that include feature aspects and link to `systems/` hardware configs
- **`users/`** - Per-user aspects (`dan.nix`, `underdel.nix`) that include feature aspects and set user-specific data

### Hardware & system configs (`systems/`)

Platform-specific NixOS `configuration.nix` and `hardware-configuration.nix` files, imported by host aspects.

### Hosts

| Host | System | Class | Users |
|------|--------|-------|-------|
| DanPC | x86_64-linux | nixos | dan |
| framnix | x86_64-linux | nixos | dan, underdel |
| MacBook | aarch64-darwin | darwin | dan |

Standalone home profiles: `dan@DanPC`, `dan@framnix`, `dan@MacBook`, `underdel@framnix`.

## Conventions

- Formatter is **alejandra** (not nixfmt). Run `nix fmt` before committing.
- Linter is **statix**. W20 (repeated keys) is disabled globally.
- Secrets are managed with **sops-nix** (config in `.sops.yaml`, encrypted files in `homes/dan/sops/`).
- Theming uses **Catppuccin mocha** via the catppuccin flake input.
- Custom packages live in `packages/`.
