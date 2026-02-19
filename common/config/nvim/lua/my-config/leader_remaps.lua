-- vim.keymap.set("n", "<leader>rf", vim.lsp.buf.format)

-- remaps for moving current line to another line
vim.keymap.set("n", "<leader>t", ":-")
vim.keymap.set("n", "<leader>b", ":+")

vim.keymap.set("n", "<leader>re", ":registers<cr>")
vim.keymap.set("n", "<leader>co", ":%bd|e#<cr>")
vim.keymap.set("n", "<leader><space>", ":nohlsearch<cr>")

vim.keymap.set("n", "<leader>vs", ":vs<cr>")
-- commented out in favour of the window-picker.lua plugin
-- vim.keymap.set("n", "<leader>w", "<C-w><C-w>")

-- Copy to main clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set({ "n", "v" }, "<leader>pa", [["+p]])
vim.keymap.set("n", "<leader>Pa", [["+P]])

-- on main rc file
vim.keymap.set("n", "<leader>sv", ":lua require('my-config.reloader').my_config_reload_config()<cr>")
vim.keymap.set("n", "<leader>ev", ":tabedit $MYVIMRC<cr>")
