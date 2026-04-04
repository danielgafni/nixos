{den, ...}: let
  ghPrCachePath = import ./_gh-pr-cache.nix;
in {
  den.aspects.shell = {
    homeManager = {
      config,
      lib,
      ...
    }: let
      d = config.xdg.dataHome;
      c = config.xdg.configHome;
      cache = config.xdg.cacheHome;
    in {
      home.sessionVariables = {
        LESSHISTFILE = cache + "/less/history";
        LESSKEY = c + "/less/lesskey";
        WINEPREFIX = d + "/wine";
        XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
        DELTA_PAGER = "less -R";
        EDITOR = "nvim";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        TERRAGRUNT_PROVIDER_CACHE = "1";
        PULUMI_IGNORE_AMBIENT_PLUGINS = "true";
        STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
      };

      home.sessionPath = [
        "$HOME/bin"
        "$HOME/.local/bin"
        "$HOME/.cargo/env"
        "$HOME/.yarn/bin"
        "$HOME/.cache/.bun/bin"
        "$HOME/.pyenv/bin"
      ];

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        starship = {
          enable = true;
          settings = {
            character = {
              success_symbol = "[›](bold green)";
              error_symbol = "[›](bold red)";
            };
            git_status = {
              deleted = "✗";
              modified = "✶";
              staged = "✓";
              stashed = "≡";
            };
            nix_shell = {
              symbol = " ";
              heuristic = true;
            };
            kubernetes = {
              disabled = true;
              symbol = "☸ ";
            };
            aws = {
              symbol = "🅰 ";
            };
            gcloud = {
              disabled = true;
              symbol = "🇬️";
            };
            custom.github_pr = {
              command = ghPrCachePath + ''[ -f "$cache_file" ] && cat "$cache_file"'';
              when = "git rev-parse --git-dir 2>/dev/null";
              format = "$output ";
              shell = ["bash" "--noprofile" "--norc"];
            };
          };
        };

        zsh = {
          enable = true;
          autosuggestion.enable = true;
          autocd = false;
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
            share = true;
          };
          historySubstringSearch = {
            enable = true;
            searchUpKey = ["^[OA"];
            searchDownKey = ["^[OB"];
          };
          completionInit = ''
            autoload -U compinit && compinit
            zstyle ':completion:*' completer _complete _ignored _approximate
            zstyle ':completion:*' list-colors '\'
            zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
            zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
            zstyle ':completion:*' menu select
            zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
            zstyle ':completion:*' verbose true
            _comp_options+=(globdots)
          '';
          sessionVariables = {
            ZSH_CACHE_DIR = "$HOME/.cache/zsh";
            PYENV_VIRTUALENV_DISABLE_PROMPT = "1";
            PYENV_ROOT = "$HOME/.pyenv";
            PYTHON_KEYRING_BACKEND = "keyring.backends.fail.Keyring";
            USE_GKE_GCLOUD_AUTH_PLUGIN = "True";
            DAGSTER_HOME = "$HOME/.dagster_home";
          };
          initContent = lib.mkMerge [
            (lib.mkOrder 500 ''
              fpath+=~/.zfunc
              bindkey "^[[1;5C" forward-word
              bindkey "^[[1;5D" backward-word
            '')
            ''
              # Google Cloud SDK
              if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi
              if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi
              command_not_found_handler() { , "$@"; }
              function y() {
                local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
                yazi "$@" --cwd-file="$tmp"
                if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then builtin cd -- "$cwd"; fi
                rm -f -- "$tmp"
              }
              # Background GitHub PR cache updater for starship
              _update_gh_pr_cache() {
                (
                  git_root=$(git rev-parse --show-toplevel 2>/dev/null) || return
                  branch=$(git branch --show-current 2>/dev/null) || return
                  [ -z "$branch" ] && return
                  [ "$branch" = "main" ] || [ "$branch" = "master" ] && return
                  ${ghPrCachePath}
                  mkdir -p "$cache_dir"
                  if [ -f "$cache_file" ]; then
                    age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null) ))
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
                    check_runs=$(gh api "repos/{owner}/{repo}/commits/$sha/check-runs" --jq '[.check_runs[] | .conclusion // "pending"] | if any(. == "pending") then "pending" elif any(. == "failure" or . == "timed_out" or . == "cancelled") then "failure" elif length == 0 then "none" else "success" end' 2>/dev/null)
                    commit_status=$(gh api "repos/{owner}/{repo}/commits/$sha/status" --jq '.state' 2>/dev/null)
                    if [ "$check_runs" = "pending" ] || [ "$commit_status" = "pending" -a "$check_runs" = "none" ]; then ci_state="pending"
                    elif [ "$check_runs" = "failure" ] || [ "$commit_status" = "failure" ] || [ "$commit_status" = "error" ]; then ci_state="failure"
                    elif [ "$check_runs" = "success" ] || [ "$commit_status" = "success" ]; then ci_state="success"
                    else ci_state="pending"; fi
                    if [ "$merged_at" != "null" ]; then color="4;9;35"
                    elif [ "$state" = "closed" ]; then color="4;9;31"
                    elif [ "$ci_state" = "pending" ]; then color="4;33"
                    elif [ "$ci_state" = "failure" ] || [ "$ci_state" = "error" ]; then color="4;31"
                    else color="4;32"; fi
                    if [ "$draft" = "true" ]; then color="2;$color"; fi
                    printf '\e[%sm\e]8;;%s\e\\PR #%s\e]8;;\e\\\e[0m' "$color" "$url" "$num" > "$cache_file"
                  else rm -f "$cache_file"; fi
                ) &>/dev/null &!
              }
              precmd_functions+=(_update_gh_pr_cache)
            ''
          ];
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
      };
    };
  };
}
