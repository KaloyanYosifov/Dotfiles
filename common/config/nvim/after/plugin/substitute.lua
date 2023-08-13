local substitute = require("substitute")

substitute.setup()

vim.keymap.set("n", "gr", require('substitute').operator, { noremap = true })
vim.keymap.set("n", "grr", require('substitute').line, { noremap = true })
vim.keymap.set("x", "gr", require('substitute').visual, { noremap = true })
