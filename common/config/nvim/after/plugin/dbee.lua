local dbee = require("dbee")

dbee.setup()

-- Keymaps
vim.keymap.set("n", "<leader>db", dbee.toggle)
