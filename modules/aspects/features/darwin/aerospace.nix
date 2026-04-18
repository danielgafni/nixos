_: {
  den.aspects.aerospace = {
    homeManager = {
      pkgs,
      config,
      ...
    }: let
      inherit (config.my) keymap;

      toStr = builtins.toString;
      mkWorkspaceBindings = prefix: action:
        builtins.listToAttrs (map (w: {
            name = "${prefix}-${w.key}";
            value = "${action} ${toStr w.workspace}";
          })
          keymap.workspaces);

      # Immediate lock via macOS's built-in Ctrl+Cmd+Q.
      # Requires Accessibility permission for the osascript binary (prompted once).
      lockScript = pkgs.writeShellScript "aerospace-lock" ''
        /usr/bin/osascript -e 'tell application "System Events" to keystroke "q" using {command down, control down}'
      '';
    in {
      programs.aerospace = {
        enable = true;
        settings = {
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;

          default-root-container-layout = "tiles";
          default-root-container-orientation = "auto";

          # Notify sketchybar on every workspace change so the bar can highlight
          # the focused workspace reactively.
          exec-on-workspace-change = [
            "/bin/bash"
            "-c"
            "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
          ];

          gaps = {
            outer = {
              left = 3;
              bottom = 3;
              top = 3;
              right = 3;
            };
            inner = {
              horizontal = 3;
              vertical = 3;
            };
          };

          mode.main.binding =
            (mkWorkspaceBindings "alt" "workspace")
            // (mkWorkspaceBindings "alt-shift" "move-node-to-workspace")
            // {
              "alt-${keymap.keys.fullscreen}" = "fullscreen";
              "alt-${keymap.keys.killWindow}" = "close";
              "alt-${keymap.keys.cycleWindowInGroup}" = "focus next";
              "alt-${keymap.keys.floating}" = "layout floating tiling";
              "alt-${keymap.keys.lock}" = "exec-and-forget ${lockScript}";
              "alt-${keymap.keys.fileManager}" = "exec-and-forget /usr/bin/open -a Finder";

              "alt-enter" = "exec-and-forget open -na Ghostty";
            };
        };
      };
    };
  };
}
