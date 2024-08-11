local projects_storage = os.getenv("HOME") .. "/.vim/projects"

return {
	{
		"ahmedkhalf/project.nvim",
		init = function()
			require("telescope").load_extension("projects")

			vim.keymap.set("n", "<leader>pm", ":Telescope projects<cr>")

			if vim.fn.isdirectory(projects_storage) == 0 then
				vim.print("Creating")
				vim.fn.mkdir(projects_storage)
			end
		end,
		opts = {
			show_hidden = true,
			datapath = projects_storage,
		},
		config = function(_, opts)
			require("project_nvim").setup(opts)
		end,
	},
}
