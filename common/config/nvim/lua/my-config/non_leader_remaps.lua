local utils = require("my-config.utils")

local move_up_key = "<A-j>"
local move_down_key = "<A-k>"

if vim.fn.has("macunix") then
	move_up_key = "∆"
	move_down_key = "˚"
end

vim.keymap.set("n", move_up_key, ":m +1<cr>")
vim.keymap.set("n", move_down_key, ":m -2<cr>")

vim.keymap.set("i", move_up_key, "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", move_down_key, "<Esc>:m .-2<CR>==gi")

vim.keymap.set("v", move_up_key, "<Esc>:m .+1<CR>==gi")
vim.keymap.set("v", move_down_key, "<Esc>:m .-2<CR>==gi")

vim.keymap.set("n", "<S-j>", ":tabprev<cr>")
vim.keymap.set("n", "<S-k>", ":tabnext<cr>")

vim.keymap.set("n", "gY", function()
	local abs_path = vim.fn.expand("%:p")

	if abs_path == "" then
		vim.notify("No file to copy path from", vim.log.levels.WARN)
		return
	end

	utils.copy_path_picker(abs_path, vim.fn.line("."))
end, { desc = "Copy path picker", noremap = true, silent = true })
