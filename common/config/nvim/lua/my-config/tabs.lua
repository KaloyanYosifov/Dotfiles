local snacks = require("snacks")

local visible_tab = vim.api.nvim_get_current_tabpage()
local tab_stack = {}
local M = {}

M.go_to_previous = function()
	local last_tab = table.remove(tab_stack)

	while last_tab ~= nil and not vim.api.nvim_tabpage_is_valid(last_tab) do
		last_tab = table.remove(tab_stack)
	end

	if last_tab == nil then
		snacks.notify("No previous tab to go to", { level = "error" })
		return
	end

	vim.api.nvim_set_current_tabpage(last_tab)
end

M.setup = function()
	vim.api.nvim_create_autocmd("TabEnter", {
		group = vim.api.nvim_create_augroup("WatchTabs", { clear = true }),
		callback = function()
			table.insert(tab_stack, visible_tab)
			visible_tab = vim.api.nvim_get_current_tabpage()
		end,
	})
end

return M
