#!/usr/bin/env bash
# get-workspaces.sh: get an array of json objects representing workspaces that are in use
# Based on a script from https://wiki.hyprland.org/hyprland-wiki/pages/Useful-Utilities/Status-Bars/#eww

spaces() {
	# Sort before filtering to account for hyprland-autoname-workspaces
	hyprctl workspaces -j | jq --compact-output 'sort_by(.id) | map({id, name, window})'
}

spaces
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r _; do
	spaces
done
