local utils = require("my-config.utils")
local snacks = require("snacks")
local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local close_tab = function(bufnr)
	local current_picker = action_state.get_current_picker(bufnr)
	local current_entry = action_state:get_selected_entry()
	if vim.api.nvim_get_current_tabpage() == current_entry.value[5] then
		vim.notify("You cannot close the currently visible tab :(", vim.log.levels.ERROR)
		return
	end
	current_picker:delete_selection(function(selection)
		for _, wid in ipairs(selection.value[4]) do
			vim.api.nvim_win_close(wid, false)
		end
	end)
end

local M = {}

local default_conf = {
	entry_formatter = function(tab_id, file_names, is_current)
		local entry_string = table.concat(file_names, ", ")
		return string.format("%d: %s%s", tab_id, entry_string, is_current and " <" or "")
	end,
	entry_ordinal = function(file_names)
		return table.concat(file_names, " ")
	end,
	close_tab_shortcut_i = "<C-d>",
	close_tab_shortcut_n = "D",
}

M.conf = default_conf

M.setup = function(opts)
	utils.normalize(opts, M.conf)
end

M.list_tabs = function(opts)
	opts = vim.tbl_deep_extend("force", M.conf, opts or {})

	local res = {}
	local current_tab = { number = vim.api.nvim_tabpage_get_number(0), index = nil }

	for index, tid in ipairs(vim.api.nvim_list_tabpages()) do
		local file_names = {}
		local file_paths = {}
		local file_ids = {}
		local window_ids = {}
		local is_current = current_tab.number == vim.api.nvim_tabpage_get_number(tid)

		for _, wid in ipairs(vim.api.nvim_tabpage_list_wins(tid)) do
			if vim.api.nvim_win_get_config(wid).relative == "" then
				local bid = vim.api.nvim_win_get_buf(wid)
				local path = vim.api.nvim_buf_get_name(bid)
				local file_name = vim.fn.fnamemodify(path, ":t")

				table.insert(file_names, file_name)
				table.insert(file_paths, path)
				table.insert(file_ids, bid)
				table.insert(window_ids, wid)
			end
		end

		if is_current then
			current_tab.index = index
		end

		table.insert(res, { file_names, file_paths, file_ids, window_ids, tid, is_current })
	end

	pickers
		.new(opts, {
			prompt_title = "Tabs",

			finder = finders.new_table({
				results = res,
				entry_maker = function(entry)
					local entry_string = opts.entry_formatter(entry[5], entry[1], entry[6])
					local ordinal_string = opts.entry_ordinal(entry[1])
					return {
						value = entry,
						path = entry[2][1],
						display = entry_string,
						ordinal = ordinal_string,
					}
				end,
			}),

			sorter = conf.generic_sorter({}),

			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					if not selection then
						snacks.notify("No matching tab found", vim.log.levels.WARN)
						return
					end
					actions.close(prompt_bufnr)
					vim.api.nvim_set_current_tabpage(selection.value[5])
				end)

				map("i", opts.close_tab_shortcut_i, close_tab)
				map("n", opts.close_tab_shortcut_n, close_tab)

				return true
			end,

			previewer = conf.file_previewer({}) or nil,

			on_complete = {
				function(picker)
					picker:set_selection(current_tab.index - 1)
				end,
			},
		})
		:find()
end

return M
