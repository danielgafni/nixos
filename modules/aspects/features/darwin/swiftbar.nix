# SwiftBar with an AeroSpace workspace plugin.
# Plugin lives at ~/Library/Application Support/SwiftBar/Plugins/aerospace.1m.sh
# and is refreshed on every AeroSpace workspace change (see aerospace.nix).
_: {
  den.aspects.swiftbar = {
    homeManager = {pkgs, ...}: let
      aerospace = "${pkgs.aerospace}/bin/aerospace";
      pluginScript = pkgs.writeShellScript "aerospace-swiftbar" ''
        #!/usr/bin/env bash
        set -e

        FOCUSED=$(${aerospace} list-workspaces --focused 2>/dev/null || echo "")
        ALL=$(${aerospace} list-workspaces --all 2>/dev/null || echo "")

        # Inline menubar title: focused workspace wrapped in [brackets].
        TITLE="⌥"
        for ws in $ALL; do
          if [ "$ws" = "$FOCUSED" ]; then
            TITLE="$TITLE [$ws]"
          else
            TITLE="$TITLE $ws"
          fi
        done
        echo "$TITLE | font='JetBrainsMono Nerd Font' size=13"
        echo "---"
        for ws in $ALL; do
          if [ "$ws" = "$FOCUSED" ]; then
            echo "✓ Workspace $ws | shell='${aerospace}' param1='workspace' param2='$ws' terminal=false refresh=true"
          else
            echo "  Workspace $ws | shell='${aerospace}' param1='workspace' param2='$ws' terminal=false refresh=true"
          fi
        done
      '';
    in {
      home.packages = [pkgs.swiftbar];

      # SwiftBar's default plugin directory (configurable in its GUI too).
      home.file."Library/Application Support/SwiftBar/Plugins/aerospace.1m.sh".source = pluginScript;

      # Auto-start SwiftBar at login.
      launchd.agents.swiftbar = {
        enable = true;
        config = {
          ProgramArguments = [
            "${pkgs.swiftbar}/Applications/SwiftBar.app/Contents/MacOS/SwiftBar"
          ];
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/tmp/swiftbar.log";
          StandardErrorPath = "/tmp/swiftbar.err.log";
        };
      };
    };
  };
}
