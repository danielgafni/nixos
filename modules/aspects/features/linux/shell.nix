_: {
  den.aspects.shell-linux = {
    homeManager = _: {
      programs.zsh.shellAliases = {
        hyprlock-restart = "hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1' && hyprctl --instance 0 'dispatch exec hyprlock'";
        hyprland-logs-tty = "cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log";
        hyprland-logs = "cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 2 | tail -n 1)/hyprland.log";
      };
    };
  };
}
