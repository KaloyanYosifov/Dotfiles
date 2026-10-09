local snacks = require("snacks")

local previous_tab
local previous_path
local tab_stack = {}
local M = {}

M.go_to_previous = function()
	local last_tab = table.remove(tab_stack)

	if last_tab == nil then
		snacks.notify("No previous tab to go to", { level = "error" })
		return
	elseif not vim.api.nvim_tabpage_is_valid(last_tab.tab) then
		if last_tab.path then
			vim.cmd("tabnew " .. vim.fn.fnameescape(last_tab.path))

			snacks.notify(
				"Re-opened previous file in new tab: " .. vim.fn.fnamemodify(last_tab.path, ":t"),
				{ level = "info" }
			)
		end
	else
		vim.api.nvim_set_current_tabpage(last_tab.tab)
	end
end

M.setup = function()
	previous_tab = vim.api.nvim_get_current_tabpage()
	previous_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

	local group = vim.api.nvim_create_augroup("WatchTabs", { clear = true })
	local add_tab = function()
		local current_tab = vim.api.nvim_get_current_tabpage()
		local current_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

		-- A new tab fires TabEnter and then TabNewEntered. Only the first is a tab change,
		-- the second just knows the file the new tab opened.
		if current_tab == previous_tab then
			previous_path = current_path
			return
		end

		table.insert(tab_stack, { tab = previous_tab, path = previous_path })

		previous_tab = current_tab
		previous_path = current_path
	end

	vim.api.nvim_create_autocmd("TabEnter", {
		group = group,
		callback = add_tab,
	})

	vim.api.nvim_create_autocmd("TabNewEntered", {
		group = group,
		callback = add_tab,
	})
end

return M
