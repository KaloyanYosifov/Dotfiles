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
