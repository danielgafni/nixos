_: {
  den.aspects.aerospace = {
    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: let
      inherit (config.my) keymap;

      # Path where programs.aerospace writes aerospace.toml. Mirrors the upstream
      # module's logic so we can override the file's onChange hook below.
      aerospaceConfigPath =
        if config.xdg.enable
        then "${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/aerospace/aerospace.toml"
        else ".aerospace.toml";

      mkWorkspaceBindings = prefix: action:
        builtins.listToAttrs (map (w: {
            name = "${prefix}-${w.key}";
            value = "${action} ${toString w.workspace}";
          })
          keymap.workspaces);
    in {
      # Tolerate `aerospace reload-config` failing when AeroSpace isn't running
      # yet (first install): launchd will still bootstrap it afterward.
      home.file.${aerospaceConfigPath}.onChange = lib.mkForce ''
        ${lib.getExe pkgs.aerospace} reload-config 2>&1 \
          || echo "AeroSpace not running yet — reload-config skipped; launchd will start it."
      '';

      programs.aerospace = {
        enable = true;
        launchd = {
          enable = true;
          keepAlive = true;
        };
        settings = {
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;

          default-root-container-layout = "tiles";
          default-root-container-orientation = "auto";

          gaps = {
            outer = {
              left = 3;
              bottom = 3;
              top = 3;
              right = 3;
            };
            inner = {
              horizontal = 8;
              vertical = 8;
            };
          };

          mode.main.binding =
            (mkWorkspaceBindings "alt" "workspace")
            // (mkWorkspaceBindings "alt-shift" "move-node-to-workspace")
            // {
              "alt-${keymap.keys.fullscreen}" = "fullscreen";
              "alt-shift-${keymap.keys.fullscreen}" = "flatten-workspace-tree";
              "alt-${keymap.keys.killWindow}" = "close";
              "alt-${keymap.keys.cycleWindowInGroup}" = "focus dfs-next";
              "alt-${keymap.keys.floating}" = "layout floating tiling";
              "alt-slash" = "layout tiles horizontal vertical";
              "alt-period" = "layout accordion horizontal vertical";
              "alt-${keymap.keys.fileManager}" = "exec-and-forget /usr/bin/open -a Finder";

              "alt-enter" = "exec-and-forget open -na Ghostty";

              "alt-h" = "focus left";
              "alt-j" = "focus down";
              "alt-k" = "focus up";
              "alt-l" = "focus right";

              "alt-shift-h" = "move left";
              "alt-shift-j" = "move down";
              "alt-shift-k" = "move up";
              "alt-shift-l" = "move right";

              "alt-cmd-h" = "join-with left";
              "alt-cmd-j" = "join-with down";
              "alt-cmd-k" = "join-with up";
              "alt-cmd-l" = "join-with right";
            };
        };
      };
    };
  };
}
