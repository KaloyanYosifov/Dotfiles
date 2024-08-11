return {
	{
		"nvim-telescope/telescope.nvim",
		version = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
		init = function()
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
			vim.keymap.set("n", "<C-p>", builtin.git_files, {})
			vim.keymap.set("n", "<leader>f", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
		end,
		opts = {
			defaults = {
				vimgrep_arguments = {
					"rg",
					"--hidden",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				file_ignore_patterns = {
					"^.git/",
					"%.lock",
					"^public/",
					"^target/",
					"%-lock.json",
					"^node_modules/",
				},
				mappings = {
					i = {
						["<CR>"] = "select_tab",
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
					},
				},
			},
		},
	},
}
