-- Loaded by scripts/test.sh and by every child Neovim the unit tests start.
-- Puts only this config's lua/ and mini.test on the runtimepath, no plugins.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(root .. "/tests/.deps/mini.test")
vim.o.swapfile = false

require("mini.test").setup()
