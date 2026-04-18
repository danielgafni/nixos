_: {
  den.aspects.sketchybar = {
    homeManager = {pkgs, ...}: {
      programs.sketchybar = {
        enable = true;
        extraPackages = [pkgs.aerospace];
        config.text = ''
          #!/usr/bin/env bash

          # Catppuccin mocha palette
          BASE=0xff1e1e2e
          TEXT=0xffcdd6f4
          BLUE=0xff89b4fa
          MAUVE=0xffcba6f7
          ACCENT=$BLUE

          sketchybar --bar \
            position=top \
            height=32 \
            blur_radius=30 \
            color=$BASE

          sketchybar --default \
            icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
            icon.color=$TEXT \
            label.font="JetBrainsMono Nerd Font:Bold:13.0" \
            label.color=$TEXT \
            padding_left=5 \
            padding_right=5 \
            icon.padding_left=4 \
            icon.padding_right=4 \
            label.padding_left=4 \
            label.padding_right=4 \
            background.corner_radius=4 \
            background.height=22

          # AeroSpace workspace change event (emitted from AeroSpace's exec-on-workspace-change)
          sketchybar --add event aerospace_workspace_change

          # Workspace indicators: highlight the focused workspace.
          for i in 1 2 3 4 5 6 7 8 9; do
            sketchybar --add item space.$i left \
              --subscribe space.$i aerospace_workspace_change \
              --set space.$i \
                label="$i" \
                label.color=$TEXT \
                background.color=$ACCENT \
                background.drawing=off \
                click_script="aerospace workspace $i" \
                script="if [ \"\$FOCUSED_WORKSPACE\" = \"$i\" ]; then sketchybar --set \$NAME background.drawing=on label.color=$BASE; else sketchybar --set \$NAME background.drawing=off label.color=$TEXT; fi"
          done

          # Right-side items (added right→left appear outer→inner)
          sketchybar --add item clock right \
            --set clock \
              update_freq=10 \
              script='sketchybar --set $NAME label="$(date "+%a %d %b  %H:%M")"'

          sketchybar --add item battery right \
            --set battery \
              update_freq=30 \
              script='pct=$(/usr/bin/pmset -g batt | /usr/bin/grep -Eo "[0-9]+%" | /usr/bin/tr -d %); charging=$(/usr/bin/pmset -g batt | /usr/bin/grep -c "AC Power"); lbl="$pct%"; [ "$charging" = "1" ] && lbl="⚡$lbl"; sketchybar --set $NAME label="$lbl"'

          sketchybar --add item wifi right \
            --set wifi \
              update_freq=15 \
              script='ssid=$(/usr/sbin/networksetup -getairportnetwork en0 2>/dev/null | /usr/bin/awk -F": " "/Current Wi-Fi Network/ {print \$2}"); [ -z "$ssid" ] && ssid="—"; sketchybar --set $NAME label="$ssid"'

          sketchybar --add item volume right \
            --set volume \
              update_freq=5 \
              script='vol=$(/usr/bin/osascript -e "output volume of (get volume settings)"); muted=$(/usr/bin/osascript -e "output muted of (get volume settings)"); if [ "$muted" = "true" ]; then sketchybar --set $NAME label="🔇"; else sketchybar --set $NAME label="♪ $vol%"; fi'

          sketchybar --update

          # Seed initial workspace highlight on startup.
          sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null || echo 1)"
        '';
      };
    };
  };
}
