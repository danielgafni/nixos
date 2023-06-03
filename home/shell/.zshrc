export EDITOR=nvim
export PATH=$HOME/bin:/usr/local/bin:$PATH

# ZSH settings
export BROWSER=/usr/bin/google-chrome-stable
export ZSH_CACHE_DIR=$HOME/.cache/zsh
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY
# needed for zsh completions
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc


# ctrl+left/right arrow jumps to next word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word


# aliases
alias zj="zellij"
alias k="kubectl"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#

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

gnupg_path=$(ls $XDG_RUNTIME_DIR/gnupg)
#export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/$gnupg_path/S.gpg-agent.ssh"
export KITTY_SHELL_INTEGRATION=enabled
autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
kitty-integration
unfunction kitty-integration

# run programs that are not in PATH with comma
command_not_found_handler() {
  ${pkgs.comma}/bin/comma "$@"
}
