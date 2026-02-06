{config, ...}: let
  ghPrCachePath = import ./gh-pr-cache.nix;
in {
  programs.zsh = {
    enable = true;
    #zprof.enable = true;  # enable to profile zsh startup
    autosuggestion.enable = true;
    autocd = false; # using zoxide instead
    dirHashes = {
      dl = "$HOME/Downloads";
      docs = "$HOME/Documents";
      code = "$HOME/Documents/code";
      dots = "$HOME/Documents/code/dotfiles";
      pics = "$HOME/Pictures";
      vids = "$HOME/Videos";
      nixpkgs = "$HOME/Documents/code/git/nixpkgs";
    };
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      expireDuplicatesFirst = true;
      path = "${config.xdg.dataHome}/zsh_history";
      size = 100000;
      save = 100000;
    };

    initContent =
      builtins.readFile ./.zshrc
      + ''

        # Background GitHub PR cache updater for starship
        _update_gh_pr_cache() {
          (
            git_root=$(git rev-parse --show-toplevel 2>/dev/null) || return
            branch=$(git branch --show-current 2>/dev/null) || return
            [ -z "$branch" ] && return
            [ "$branch" = "main" ] || [ "$branch" = "master" ] && return

            ${ghPrCachePath}
            mkdir -p "$cache_dir"

            # Skip if cache is fresh (less than 5 seconds old)
            if [ -f "$cache_file" ]; then
              age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
              [ "$age" -lt 5 ] && return
            fi

            owner=$(gh repo view --json owner -q '.owner.login' 2>/dev/null) || return
            pr=$(gh api "repos/{owner}/{repo}/pulls?state=all&head=''${owner}:''${branch}" --jq '.[0] | "\(.number)|\(.html_url)|\(.state)|\(.draft)|\(.merged_at // "null")|\(.head.sha)"' 2>/dev/null)
            num=$(echo "$pr" | cut -d'|' -f1)
            url=$(echo "$pr" | cut -d'|' -f2)
            state=$(echo "$pr" | cut -d'|' -f3)
            draft=$(echo "$pr" | cut -d'|' -f4)
            merged_at=$(echo "$pr" | cut -d'|' -f5)
            sha=$(echo "$pr" | cut -d'|' -f6)

            if [ -n "$num" ] && [ "$num" != "null" ]; then
              # Get CI status from both check-runs (Actions) and commit status (legacy)
              check_runs=$(gh api "repos/{owner}/{repo}/commits/$sha/check-runs" --jq '[.check_runs[] | .conclusion // "pending"] | if any(. == "pending") then "pending" elif any(. == "failure" or . == "timed_out" or . == "cancelled") then "failure" elif length == 0 then "none" else "success" end' 2>/dev/null)
              commit_status=$(gh api "repos/{owner}/{repo}/commits/$sha/status" --jq '.state' 2>/dev/null)

              # Combine: check-runs take priority, fall back to commit status
              if [ "$check_runs" = "pending" ] || [ "$commit_status" = "pending" -a "$check_runs" = "none" ]; then
                ci_state="pending"
              elif [ "$check_runs" = "failure" ] || [ "$commit_status" = "failure" ] || [ "$commit_status" = "error" ]; then
                ci_state="failure"
              elif [ "$check_runs" = "success" ] || [ "$commit_status" = "success" ]; then
                ci_state="success"
              else
                ci_state="pending"
              fi

              # Determine color (4=underline, 9=strikethrough, 2=dim)
              if [ "$merged_at" != "null" ]; then
                color="4;9;35"  # underline + strikethrough + violet
              elif [ "$state" = "closed" ]; then
                color="4;9;31"  # underline + strikethrough + red
              elif [ "$ci_state" = "pending" ]; then
                color="4;33"  # underline + yellow
              elif [ "$ci_state" = "failure" ] || [ "$ci_state" = "error" ]; then
                color="4;31"  # underline + red
              else
                color="4;32"  # underline + green
              fi

              if [ "$draft" = "true" ]; then
                color="2;$color"  # dim
              fi

              printf '\e[%sm\e]8;;%s\e\\PR #%s\e]8;;\e\\\e[0m' "$color" "$url" "$num" > "$cache_file"
            else
              rm -f "$cache_file"
            fi
          ) &>/dev/null &!
        }
        precmd_functions+=(_update_gh_pr_cache)
      '';

    shellAliases = {
      grep = "grep --color";
      ip = "ip --color";
      l = "eza -l";
      la = "eza -la";
      md = "mkdir -p";
      cd = "z";
      k = "kubectl";
      zj = "zellij";
      pr = "gh pr view --web";
      devbox-start = "aws ec2 start-instances --instance-ids i-04faa7b6877e3da94 --region eu-north-1";
      devbox-stop = "aws ec2 stop-instances --instance-ids i-04faa7b6877e3da94 --region eu-north-1";
      hyprlock-restart = "hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1' && hyprctl --instance 0 'dispatch exec hyprlock'";
      hyprland-logs-tty = "cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log";
      hyprland-logs = "cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 2 | tail -n 1)/hyprland.log";
    };
    shellGlobalAliases = {
      eza = "eza --icons --git";
    };
    zplug = {
      enable = true;
      plugins = [
        {name = "zdharma-continuum/fast-syntax-highlighting";}
        {
          name = "chisui/zsh-nix-shell";
          tags = ["lazy:true"];
        }
      ];
    };
  };
}
