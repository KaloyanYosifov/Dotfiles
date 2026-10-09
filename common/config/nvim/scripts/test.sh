#! /usr/bin/env bash
# Runs the config test suite with mini.test.
#   scripts/test.sh                       all tests
#   scripts/test.sh tests/test_crypt.lua  one file
# Set NVIM_BIN to use a different nvim binary.
set -euo pipefail

cd "$(dirname "$0")/.."

nvim_bin="${NVIM_BIN:-nvim}"
mini_test_dir="tests/.deps/mini.test"

if [ ! -d "$mini_test_dir" ]; then
    git clone --filter=blob:none https://github.com/nvim-mini/mini.test "$mini_test_dir"
fi

if [ $# -gt 0 ]; then
    files=$(printf '"%s",' "$@")
    exec "$nvim_bin" --headless --noplugin -u tests/minimal_init.lua \
        -c "lua MiniTest.run({ collect = { find_files = function() return { ${files%,} } end } })"
fi

exec "$nvim_bin" --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"
