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
		version = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
		init = function()
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
			vim.keymap.set("n", "<C-p>", project_files, {})
			vim.keymap.set("n", "<leader>f", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})

			-- Commented out for now, since I am only using telescope for file finder
			-- hence it's not a problem for me to just remap the bindings
			-- support opening files in a new tab, but any other actions will not
			-- local actions_state = require("telescope.actions.state")
			-- local select_key_to_edit_key = actions_state.select_key_to_edit_key
			-- actions_state.select_key_to_edit_key = function(type)
			-- 	local key = select_key_to_edit_key(type)
			-- 	return key == "edit" and "tabedit" or key
			-- end
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
		},
	},
}
