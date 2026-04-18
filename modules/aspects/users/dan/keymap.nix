# Shared keymap used by Hyprland (Linux) and AeroSpace (macOS).
# Top-level option `keymap` is injected into every home-manager config as
# `my.keymap` via `ctx.home.includes` in den.nix.
{lib, ...}: {
  options.keymap = lib.mkOption {
    type = lib.types.attrs;
    default = {};
    description = "Unified window-manager keymap shared across Hyprland and AeroSpace.";
  };

  config.keymap = {
    # Each entry maps a key label (as typed) to a workspace number.
    workspaces = [
      {
        key = "1";
        workspace = 1;
      }
      {
        key = "2";
        workspace = 2;
      }
      {
        key = "3";
        workspace = 3;
      }
      {
        key = "4";
        workspace = 4;
      }
      {
        key = "5";
        workspace = 5;
      }
      {
        key = "6";
        workspace = 6;
      }
      {
        key = "7";
        workspace = 7;
      }
      {
        key = "8";
        workspace = 8;
      }
      {
        key = "9";
        workspace = 9;
      }
      {
        key = "0";
        workspace = 10;
      }
    ];

    keys = {
      fullscreen = "f";
      killWindow = "q";
      cycleWindowInGroup = "tab";
      floating = "s";
      lock = "l";
      fileManager = "e";
    };
  };
}
