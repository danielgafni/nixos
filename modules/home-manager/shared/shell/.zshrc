export PATH=$HOME/bin:/usr/local/bin:$PATH

# ZSH settings
export ZSH_CACHE_DIR=$HOME/.cache/zsh
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY
zstyle ':completion:*' menu select
fpath+=~/.zfunc

# ctrl+left/right arrow jumps to next word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Add pyenv executable to PATH and
# enable shims by adding the following
# to ~/.profile and ~/.zprofile:
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init --path)"
# Load pyenv into the shell by adding
# the following to ~/.zshrc:
#eval "$(pyenv init -)"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/env:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.cache/.bun/bin:$PATH"
export PYTHON_KEYRING_BACKEND=keyring.backends.fail.Keyring

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/dan/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/home/dan/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/dan/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/dan/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# for Dagster
export DAGSTER_HOME=$HOME/.dagster_home

# search history based on what's typed in the prompt
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[OA" history-beginning-search-backward-end
bindkey "^[OB" history-beginning-search-forward-end

# case insensitive tab completion
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' list-colors '\'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose true
_comp_options+=(globdots)

# run programs that are not in PATH with comma
command_not_found_handler() {
  , "$@"
}

# Direnv
eval "$(direnv hook zsh)"

# Yazi - change cwd on exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
