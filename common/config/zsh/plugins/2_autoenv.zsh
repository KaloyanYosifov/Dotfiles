source "$ZSH_DIR/plugin-utils.zsh"

__plugin_load_plugin "autoenv" "__NO_REPO_"

export AUTOENV_IN_FILE=__env.in
export AUTOENV_OUT_FILE=__env.out

# Only when we have a file while this plugin is sourced would we try to load it
if [[ -f $AUTOENV_IN_FILE ]]; then
    autoenv_check_and_exec "$(pwd)/$AUTOENV_IN_FILE" "$(pwd)"
fi
