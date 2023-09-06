###########################################################
# ENVIRONMENTS #
###########################################################

HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
ZSH_DIR="$HOME/.config/zsh"

function not_in_path {
    echo $PATH | grep -v "$1" 2>&1 > /dev/null
}

pathsToAdd=(
    "$HOME/.composer/vendor/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.volta/bin"
    "$HOME/.cargo/bin"
)

for pathToAdd in $pathsToAdd; do
    [ -d $pathToAdd ] && not_in_path $pathToAdd && PATH="$PATH:$pathToAdd"
done

export HOMEBREW_NO_AUTO_UPDATE=1
export VI_MODE_SET_CURSOR=true
export NVIM_CONFIG=$HOME/.config/nvim
export GPG_TTY=$(tty)
export EDITOR="nvim"
export TERM=xterm-256color

fpath=(/usr/local/share/zsh-completions $fpath)

###########################################################
# INIT #
###########################################################

setopt prompt_subst # Support substituing functions on prompt
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.

autoload -Uz compinit
compinit
_comp_options+=(globdots)		# Include hidden files.

! [[ -f $HISTFILE ]] && mkdir -p $(dirname $HISTFILE) && touch $HISTFILE

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

skipFiles=("." ".." "lead.sh" ".git" ".gitignore" "environments-mac" "environments-linux" "before-init" "tags")

if [[ -d $ZSH_DIR ]]; then
   for envFile in $ZSH_DIR/*; do
	containsElement $(basename $envFile) "${skipFiles[@]}" || source $envFile
   done
fi

command -v copyq 2>&1 > /dev/null
if [[ $? -eq 0 ]]; then
    # Autostart copyq if we haven't
    pidof copyq 2>&1 > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Starting copyq daemon"
        copyq --start-server
    fi
fi

###########################################################
# PLUGINS #
###########################################################

for i in $(ls $ZSH_DIR/plugins); do
    source $ZSH_DIR/plugins/$i
done

###########################################################
# THEME #
###########################################################

source $ZSH_DIR/themes/gentoo-theme.zsh

###########################################################
# BINDINGS #
###########################################################

bindkey -s '^o' 'open_project\n'
bindkey -s '^s' 'open_scratch\n'
