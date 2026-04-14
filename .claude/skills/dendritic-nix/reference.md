# Dendritic Nix & Den Framework - Complete Reference

## 1. The Dendritic Pattern

The Dendritic pattern is an architectural approach for organizing Nix configurations using the Nixpkgs module system. It establishes a **top-level configuration** that orchestrates lower-level configurations (NixOS, home-manager, nix-darwin, etc.).

### Core Rules

- **Every non-entry-point file is a module** in the top-level configuration
- Each module implements a **single feature** spanning all applicable configurations
- File paths are descriptive names for features, freely renamable/relocatable
- Lower-level modules are stored as option values using `deferredModule` type
- All files are auto-imported via `import-tree` - no manual import lists

### Benefits

1. **Type clarity** - all non-entry files are top-level modules, no ambiguity
2. **Automatic import** - simple expressions or import-tree handle discovery
3. **Path flexibility** - files represent features, not structural requirements

### Anti-Pattern: specialArgs

The Dendritic pattern eliminates `specialArgs` injection. Instead of threading values through multiple evaluation boundaries, every file accesses shared values via the top-level configuration's `config` namespace.

---

## 2. Den Framework

Den is a configuration library built on the Dendritic pattern. It provides aspects, contexts, schemas, and batteries for composable Nix configurations.

### Architecture Layers

| Layer | Purpose | Example |
|-------|---------|---------|
| **Schema** | Entity declaration | `den.hosts.x86_64-linux.laptop` |
| **Aspects** | Behavioral configuration | `den.aspects.laptop.nixos` |
| **Context** | Data flow transformation | `den.ctx.host` pipeline |
| **Batteries** | Reusable patterns | `den.provides.primary-user` |

### Design Philosophy

- **No lock-in** - works with flake-parts, without flake-parts, or without flakes entirely
- **Composable** - all components optional and replaceable
- **Social** - enables aspect library sharing across stable/unstable boundaries
- **Library-first** - never directly uses `lib.evalModules`, provides APIs compatible with any module system

---

## 3. Aspects

An aspect is an attrset that contains modules of different Nix classes. Instead of organizing configuration by host, aspects organize by **concern/feature**.

### Structure

```nix
den.aspects.gaming = {
  # Modules for different classes
  nixos = { pkgs, ... }: {
    programs.steam.enable = true;
  };
  homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.lutris ];
  };
  darwin = { pkgs, ... }: {
    homebrew.casks = [ "steam" ];
  };

  # Dependency management
  includes = [ den.provides.gpu-drivers ];
};
```

### Key Properties

- **Multi-class** - one aspect spans nixos, darwin, homeManager, user, and custom classes
- **Dependency graph** - `includes` declares dependencies forming a DAG
- **Namespaced** - aspects publishable across flakes via `den.ful`
- **Parametric** - aspect functions receive context data (`{host}`, `{host, user}`) as arguments

### Parametric Dispatch

Den uses **function parameter inspection** (`__functor` argument introspection) to determine when aspects apply:

- `{ nixos.networking.firewall.enable = true; }` - static, runs in all contexts
- `{ host, ... }: { ... }` - only when host context exists
- `{ host, user, ... }: { ... }` - only when both host AND user context exist
- `{ home, ... }: { ... }` - only for standalone home configurations

The context shape IS the condition - no `mkIf` or `enable` flags needed.

### Platform Scoping via `aspect` Overrides

**Avoid `if` conditions for platform filtering.** Instead, use `aspect` overrides on host user and home declarations to create platform-specific entry points.

Both `den.hosts.<system>.<name>.users.<user>` and `den.homes.<system>.<name>` support an `aspect` attribute (defaults to the user/home name). Override it to point to a platform-specific aspect:

```nix
# Host user declarations
den.hosts.x86_64-linux.myhost.users.alice.aspect = "alice-linux";

# Standalone home declarations
den.homes.x86_64-linux."alice@myhost".aspect = "alice-linux";
den.homes.aarch64-darwin."alice@macbook".aspect = "alice-darwin";
```

The platform-specific entry point aspects include the base user aspect plus platform-specific features:

```nix
# Base (cross-platform)
den.aspects.alice = {
  includes = [ den.provides.define-user den.aspects.shared-hm ];
  homeManager = { ... };  # cross-platform packages
};

# Linux entry point
den.aspects.alice-linux = {
  includes = [ den.aspects.alice den.aspects.shared-hm-linux ];
  homeManager = { ... };  # linux-specific packages
};

# Darwin entry point
den.aspects.alice-darwin = {
  includes = [ den.aspects.alice den.aspects.shared-hm-darwin ];
  homeManager = { ... };  # darwin-specific config
};
```

This eliminates the need for `if host.class == "nixos"` or `if lib.hasSuffix "-darwin" home.system` guards. Platform scoping is structural: platform-specific aspects are only reachable from the correct entry points.

### includes vs provides

- **`includes`** - aggregates other aspects (consumes from DAG)
- **`provides`** - organizes related configurations into trees (exposes to DAG)

---

## 4. Context Pipeline

Den evaluates configurations through a context transformation pipeline.

### Standard Flow

```
host → [users] → [homes]
```

With optional branches:
```
host → wsl-host
host → [microvm-guest]
host → hm-host → [hm-user]
host → hjem-host
```

### Built-in Context Types

#### `den.ctx.host`
- **Data**: `{ host }`
- **Source**: one per `den.hosts.<system>.<name>` entry
- **Providers**: applies host's aspect; creates user contexts
- **Transitions**: routes to `user`, `hm-host`, `wsl-host`, others

#### `den.ctx.user`
- **Data**: `{ host, user }`
- **Providers**: applies user's aspect
- **Transitions**: identity to `default`

#### `den.ctx.home`
- **Data**: `{ home }`
- **Source**: one per `den.homes.<system>.<name>` entry
- **Providers**: applies home's aspect

#### `den.ctx.hm-host`
- **Data**: `{ host }`
- **Providers**: imports Home Manager OS module
- **Transitions**: creates `hm-user` per HM-class user

#### `den.ctx.hm-user`
- **Data**: `{ host, user }`
- **Providers**: forwards `homeManager` class to HM configuration

#### `den.ctx.wsl-host`
- **Data**: `{ host }`
- **Providers**: imports WSL module and creates `wsl` class forward

### Context Type Structure

```nix
den.ctx.<name> = {
  description = "Human-readable purpose";
  _ = { ... };        # Provider functions (alias: provides)
  into = { ... };     # Transformation functions to other contexts
  includes = [ ... ]; # Aspect includes
  modules = [ ... ];  # Additional modules
};
```

### Custom Contexts

```nix
den.ctx.gpu = {
  description = "GPU-enabled host";
  _.gpu = { host }: { nixos.hardware.nvidia.enable = true; };
};
den.ctx.host.into.gpu = { host }:
  lib.optional (host ? gpu) { inherit host; };
```

### Deduplication

`dedupIncludes` prevents duplicate application:
- **First occurrence**: `parametric.fixedTo` (owned configs + statics + parametric matches)
- **Subsequent**: `parametric.atLeast` (parametric matches only)

---

## 5. Schema

### Host Declaration

```nix
den.hosts.<system>.<name> = {
  # Automatically derived: class (nixos from x86_64-linux, darwin from aarch64-darwin)
  users.<userName> = {};
  # Or with aspect override for platform-specific entry point:
  users.<userName>.aspect = "<aspectName>";
};
```

Examples:
```nix
den.hosts.x86_64-linux.igloo.users.tux.aspect = "tux-linux";
den.hosts.aarch64-darwin.macbook = {};  # darwin hosts may have no users (managed by macOS)
```

### Home Declaration (standalone)

```nix
den.homes.<system>.<name> = {};
# Or with aspect override:
den.homes.<system>.<name>.aspect = "<aspectName>";
```

Examples:
```nix
den.homes.x86_64-linux."tux@igloo".aspect = "tux-linux";
den.homes.aarch64-darwin."dan@macbook".aspect = "dan-darwin";
```

### Global Defaults

```nix
den.default.homeManager.home.stateVersion = "25.11";
den.default.nixos.system.stateVersion = "25.11";
```

`den.default` applies settings universally across all hosts, users, and homes.

### User Classes

```nix
den.schema.user.classes = lib.mkDefault [ "homeManager" ];
```

None enabled by default - must be explicitly set.

---

## 6. Namespaces

Namespaces create scoped aspect libraries under `den.ful.<name>`.

### Creating

```nix
imports = [ (inputs.den.namespace "my" false) ];  # local
imports = [ (inputs.den.namespace "my" true) ];   # exported
```

Generates:
- `den.ful.<name>` - namespace container
- `<name>` - module argument shorthand
- `flake.denful.<name>` - flake output (when exported)

### Populating

```nix
my.vim = {
  homeManager.programs.vim.enable = true;
};
```

### Using

```nix
den.aspects.laptop.includes = [ my.desktop my.vim ];
```

### Upstream Integration

```nix
imports = [ (inputs.den.namespace "shared" [ inputs.team-config ]) ];
```

### Angle Bracket Syntax

```nix
den.aspects.laptop.includes = [ <my/desktop> ];
```

---

## 7. Custom Classes

Custom classes forward module content into target submodule paths on existing classes using `den.provides.forward`.

### Parameters

| Parameter | Purpose |
|-----------|---------|
| `each` | List of items to process |
| `fromClass` | Custom class name to read |
| `intoClass` | Target class for forwarding |
| `intoPath` | Destination attribute path |
| `fromAspect` | Aspect containing the class |

### Built-in User Class

```nix
den.aspects.alice.user = { pkgs, ... }: {
  packages = [ pkgs.hello ];
  extraGroups = [ "wheel" ];
};
# Forwards to users.users.alice on the host's OS class
```

### Custom Container Class Example

```nix
{ den, lib, ... }: {
  den.ctx.user.includes = [ ({ host, user }: den.provides.forward {
    each = lib.singleton user;
    fromClass = _: "container";
    intoClass = _: host.class;
    intoPath = _: [ "virtualisation" "oci-containers" "containers" user.userName ];
    fromAspect = _: den.aspects.${user.aspect};
  }) ];
}
```

### Guards and Adapters

```nix
den.provides.forward {
  # ... standard params ...
  guard = { options, ... }: lib.mkIf (options ? wsl);
  adaptArgs = { ... }: { /* modify module args */ };
};
```

---

## 8. Getting Started (From Zero)

### Directory Structure

```
./modules/              # Dendritic modules (auto-imported)
./modules/_nixos/       # Underscore prefix prevents auto-loading
./modules/den.nix       # Main Den configuration
```

### With Flakes (flake.nix)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    den.url = "github:vic/den";
    import-tree.url = "github:vic/import-tree";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = inputs: (inputs.nixpkgs.lib.evalModules {
    modules = [ (inputs.import-tree ./modules) ];
    specialArgs.inputs = inputs;
  }).config.flake;
}
```

### Without Flakes (default.nix with npins)

```nix
let
  sources = import ./npins;
  with-inputs = import sources.with-inputs sources { };
  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs.inputs = inputs;
    }).config.flake;
in
with-inputs outputs
```

### Main Den Module (modules/den.nix)

```nix
{ inputs, den, lib, ... }: {
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
  den.default.homeManager.home.stateVersion = "25.11";

  den.hosts.x86_64-linux.igloo.users.tux = {};

  den.aspects.igloo = {
    includes = [ den.provides.hostname ];
    nixos = { pkgs, ... }: {
      imports = [ ./_nixos/configuration.nix ];
      environment.systemPackages = [ pkgs.hello ];
    };
  };

  den.aspects.tux = {
    includes = [ den.provides.define-user den.provides.primary-user ];
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.vim ];
    };
  };
}
```

### Building

Use `nh` for building and switching:

```bash
nh os switch      # NixOS
nh darwin switch  # nix-darwin
nh home switch    # Home Manager
```

---

## 9. Common Batteries (den.provides.*)

| Battery | Context | Purpose |
|---------|---------|---------|
| `den.provides.hostname` | `{host}` | Sets networking.hostName from host name |
| `den.provides.define-user` | `{host, user}` | Creates users.users entry |
| `den.provides.primary-user` | `{host, user}` | Configures primary user (wheel, nix trusted, etc.) |
| `den.provides.forward` | varies | Creates custom class forwarding |

---

## 10. Output Generation

`modules/config.nix` aggregates all evaluated hosts and homes, calling:
- `host.instantiate` (defaults to `lib.nixosSystem`, `darwinSystem`, or `homeManagerConfiguration` based on class)
- Distributes to `flake.nixosConfigurations`, `flake.darwinConfigurations`, `flake.homeConfigurations`
