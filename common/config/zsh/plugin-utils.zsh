local __ZSH__BASE_PATH="$HOME/.config/zsh"
local __ZSH_EXTERNAL_PLUGIN_DIR="$__ZSH__BASE_PATH/external-plugins"

function __plugin_ensure_installed() {
    local PLUGIN=$1

    if ! [[ -d "$__ZSH_EXTERNAL_PLUGIN_DIR/$PLUGIN" ]]; then
        mkdir -p $__ZSH_EXTERNAL_PLUGIN_DIR
        git clone "$2" "$__ZSH_EXTERNAL_PLUGIN_DIR/$PLUGIN"
    fi
}

function __plugin_load_plugin() {
    __plugin_ensure_installed $1 $2

    source "$__ZSH_EXTERNAL_PLUGIN_DIR/$1"
}
