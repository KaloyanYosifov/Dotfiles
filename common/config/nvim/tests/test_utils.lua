local helpers = dofile("tests/helpers.lua")
local eq = helpers.eq

local child = MiniTest.new_child_neovim()
local T = helpers.new_set(child)

local function utils(fn, ...)
	return child.lua("return require('my-config.utils')." .. fn .. "(...)", { ... })
end

T["normalize()"] = MiniTest.new_set()

T["normalize()"]["overrides existing keys and keeps the rest"] = function()
	eq(utils("normalize", { a = 2 }, { a = 1, b = 1 }), { a = 2, b = 1 })
end

T["normalize()"]["returns existing when config is empty"] = function()
	eq(utils("normalize", {}, { a = 1 }), { a = 1 })
	eq(child.lua("return require('my-config.utils').normalize(nil, { a = 1 })"), { a = 1 })
end

T["is_empty_table()"] = function()
	eq(child.lua("return require('my-config.utils').is_empty_table(nil)"), true)
	eq(utils("is_empty_table", {}), true)
	eq(utils("is_empty_table", { 1 }), false)
end

T["file_exists()"] = function()
	eq(utils("file_exists", helpers.root .. "/init.lua"), true)
	eq(utils("file_exists", helpers.root .. "/does-not-exist.lua"), false)
	eq(utils("file_exists", " "), false)
	eq(child.lua("return require('my-config.utils').file_exists(nil)"), false)
end

T["get_env()"] = function()
	child.lua("vim.env.MY_CONFIG_TEST_VAR = 'set'")

	eq(utils("get_env", "MY_CONFIG_TEST_VAR", "default"), "set")
	eq(utils("get_env", "MY_CONFIG_TEST_MISSING", "default"), "default")
end

T["command_exists()"] = function()
	eq(utils("command_exists", "sh"), true)
	eq(utils("command_exists", "definitely-not-a-command-xyz"), false)
end

T["command_path()"] = function()
	eq(utils("command_path", "definitely-not-a-command-xyz", "/fallback/bin"), "/fallback/bin")
	eq(utils("command_path", "sh") ~= "", true)
end

T["copy_path_picker()"] = MiniTest.new_set()

local path = helpers.root .. "/lua/my-config/utils.lua"

-- Stubs vim.ui.select to pick `choice` and records registers instead of touching the real clipboard
local function pick(choice, line)
	child.fn.chdir(helpers.root)

	return child.lua(
		[[
			local choice, path, line = ...
			local result = { regs = {} }
			vim.fn.setreg = function(reg, value) result.regs[reg] = value end
			vim.ui.select = function(items, _, on_choice)
				result.offered = items
				on_choice(choice)
			end
			require("my-config.utils").copy_path_picker(path, line)
			return result
		]],
		{ choice, path, line }
	)
end

T["copy_path_picker()"]["copies the relative path"] = function()
	local result = pick("Relative path")

	eq(result.regs["+"], "lua/my-config/utils.lua")
	eq(result.regs['"'], "lua/my-config/utils.lua")
end

T["copy_path_picker()"]["copies the absolute path"] = function()
	eq(pick("Absolute path").regs["+"], path)
end

T["copy_path_picker()"]["copies the file name"] = function()
	eq(pick("Filename only").regs["+"], "utils.lua")
end

T["copy_path_picker()"]["offers the line number only when given one"] = function()
	eq(#pick("Filename only").offered, 3)

	local result = pick("Relative path with line number", 12)
	eq(#result.offered, 4)
	eq(result.regs["+"], "lua/my-config/utils.lua:12")
end

T["copy_path_picker()"]["copies nothing when cancelled"] = function()
	local regs = child.lua([[
		local regs = {}
		vim.fn.setreg = function(reg, value) regs[reg] = value end
		vim.ui.select = function(_, _, on_choice) on_choice(nil) end
		require("my-config.utils").copy_path_picker(...)
		return regs
	]], { path })

	eq(regs, {})
end

T["focus_window_on_filetype()"] = MiniTest.new_set()

local function open_target_window()
	child.lua([[
		vim.cmd("vsplit | enew")
		vim.bo.filetype = "target_ft"
		_G.target = vim.api.nvim_get_current_win()
		vim.cmd("wincmd p")
	]])
end

local function wait_for_target()
	return child.lua("return vim.wait(500, function() return vim.api.nvim_get_current_win() == _G.target end)")
end

T["focus_window_on_filetype()"]["focuses the window with that filetype"] = function()
	open_target_window()
	child.lua("require('my-config.utils').focus_window_on_filetype('target_ft')")

	eq(wait_for_target(), true)
	eq(child.api.nvim_get_mode().mode, "n")
end

T["focus_window_on_filetype()"]["enters insert mode when asked"] = function()
	open_target_window()
	child.lua("require('my-config.utils').focus_window_on_filetype('target_ft', { insert_mode = true })")

	eq(wait_for_target(), true)
	eq(child.api.nvim_get_mode().mode, "i")
end

T["clear_undo_history()"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "one" })
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "two" })
		require("my-config.utils").clear_undo_history(0)
		vim.cmd("silent! undo")
	]])

	eq(child.api.nvim_buf_get_lines(0, 0, -1, false), { "two" })

	-- history still records edits made after clearing
	child.api.nvim_buf_set_lines(0, 0, -1, false, { "three" })
	child.cmd("undo")
	eq(child.api.nvim_buf_get_lines(0, 0, -1, false), { "two" })
end

return T
