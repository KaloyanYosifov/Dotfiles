source "$ZSH_DIR/plugin-utils.zsh"

__plugin_load_plugin "autoenv" "https://github.com/zpm-zsh/autoenv"

export AUTOENV_IN_FILE=__env.in
export AUTOENV_OUT_FILE=__env.out

autoenv_check_and_exec "$(pwd)/$AUTOENV_IN_FILE" "$(pwd)"
