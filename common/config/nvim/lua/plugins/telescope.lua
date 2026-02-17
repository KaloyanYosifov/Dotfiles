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
		version = "0.2.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		keys = {
			{ "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{
				"<C-p>",
				project_files,
				desc = "Project files",
			},
			{ "<leader>f", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>vh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
			{ "<leader>ml", "<cmd>Telescope marks<cr>", desc = "Marks" },
		},
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
					"%-lock.json",
					"%.lock",
					"^target/",
					"^dist/",
					"^node_modules/",
				},
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<C-t>"] = "select_default",
					},
				},
				layout_strategy = "vertical",
			},
			pickers = {
				buffers = {
					mappings = {
						i = {
							["<CR>"] = "select_tab_drop",
						},
					},
					ignore_current_buffer = true,
					show_all_buffers = true,
					sort_last_used = true,
				},
				find_files = {
					mappings = {
						i = { ["<CR>"] = "select_tab_drop" },
					},
				},
				grep_string = {
					mappings = {
						i = { ["<CR>"] = "select_tab_drop" },
					},
				},
				live_grep = {
					mappings = {
						i = { ["<CR>"] = "select_tab_drop" },
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
		config = function(_, opts)
			local telescope = require("telescope")

			telescope.setup(opts)

			telescope.load_extension("fzf")
		end,
	},

	{
		"nvim-telescope/telescope-frecency.nvim",
		version = "1.x",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"kkharji/sqlite.lua",
		},
		config = function()
			require("telescope").load_extension("frecency")
		end,
	},

	{
		"nvim-telescope/telescope-ui-select.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			telescope.load_extension("ui-select")
		end,
	},

	{
		"my-config/telescope-tabs",
		dev = true,
		virtual = true,
		main = "my-config/telescope-tabs",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"folke/snacks.nvim",
		},
		keys = {
			{ "<leader>st", ":lua require('my-config/telescope-tabs').list_tabs()<cr>", desc = "Telescope: List tabs" },
		},
		opts = {},
	},
}
