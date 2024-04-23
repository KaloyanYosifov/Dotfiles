local telescope = require("telescope")

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = "select_tab",
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
            }
        }
    }
})

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>f", builtin.live_grep, {})
vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
