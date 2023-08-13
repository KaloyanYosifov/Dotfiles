local projects_storage = os.getenv("HOME") .. "/.vim/projects"

require("project_nvim")
    .setup({
        show_hidden = true,
        datapath = projects_storage
    })


require('telescope').load_extension('projects')

vim.keymap.set("n", "<leader>pm", ":Telescope projects<cr>")

if vim.fn.isdirectory(projects_storage) == 0 then
    print("Creating")
    vim.fn.mkdir(projects_storage)
end
