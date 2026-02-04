-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
local is_inside_work_tree = {}
local project_files = function()
	local opts = {}

	local cwd = vim.fn.getcwd()
	if is_inside_work_tree[cwd] == nil then
		vim.fn.system("git rev-parse --is-inside-work-tree")
		is_inside_work_tree[cwd] = vim.v.shell_error == 0
	end

	if is_inside_work_tree[cwd] then
		require("telescope.builtin").git_files(opts)
	else
		require("telescope.builtin").find_files(opts)
	end
end

return {
	{
		"nvim-telescope/telescope.nvim",
		version = "0.2.1",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
			{
				"nvim-telescope/telescope-frecency.nvim",
				dependencies = { "kkharji/sqlite.lua" },
			},
		},
		keys = {
			{ "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{
				"<C-p>",
				function()
					project_files()
				end,
				desc = "Project files",
			},
			{ "<leader>f", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>vh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
			{ "<leader>ml", "<cmd>Telescope marks<cr>", desc = "Marks" },
		},
		config = function()
			local telescope = require("telescope")

			telescope.load_extension("fzf")
			telescope.load_extension("frecency")
		end,
		opts = {
			defaults = {
				path_display = { "truncate" },
				filesize_limit = 10, -- MB
				vimgrep_arguments = {
					"rg",
					"--hidden",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--trim",
				},
				file_ignore_patterns = {
					"^.git/",
					"%.lock",
					"^public/",
					"^target/",
					"^dist/",
					"%-lock.json",
					"^node_modules/",
				},
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<C-t>"] = "select_default",
						["<CR>"] = "select_tab",
					},
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				frecency = {
					show_scores = false,
					show_unindexed = true,
					ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
				},
			},
		},
	},
}
