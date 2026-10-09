local helpers = dofile("tests/helpers.lua")
local eq = helpers.eq

local child = MiniTest.new_child_neovim()
local T = helpers.new_set(child, {
	pre_case = function()
		child.lua("require('my-config.non_leader_remaps')")
	end,
})

local function move_keys()
	return child.lua([[
		if vim.fn.has("macunix") == 1 then
			return { down = "∆", up = "˚", other_down = "<A-j>" }
		end
		return { down = "<A-j>", up = "<A-k>", other_down = "∆" }
	]])
end

local function set_lines(lines)
	child.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	child.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function get_lines()
	return child.api.nvim_buf_get_lines(0, 0, -1, false)
end

T["maps the move keys for this OS only"] = function()
	local keys = move_keys()

	eq(child.fn.maparg(keys.down, "n") ~= "", true)
	eq(child.fn.maparg(keys.other_down, "n"), "")
end

T["normal mode moves the line"] = function()
	local keys = move_keys()
	set_lines({ "a", "b", "c" })

	child.type_keys(keys.down)
	eq(get_lines(), { "b", "a", "c" })

	child.type_keys(keys.up)
	eq(get_lines(), { "a", "b", "c" })
end

T["insert mode moves the line and stays in insert mode"] = function()
	local keys = move_keys()
	set_lines({ "a", "b", "c" })

	child.type_keys("i", keys.down)
	eq(get_lines(), { "b", "a", "c" })
	eq(child.api.nvim_get_mode().mode, "i")
end

T["visual mode moves the selection and keeps it selected"] = function()
	local keys = move_keys()
	set_lines({ "a", "b", "c", "d" })

	child.type_keys("Vj", keys.down)
	eq(get_lines(), { "c", "a", "b", "d" })
	eq(child.api.nvim_get_mode().mode, "V")

	child.type_keys(keys.up)
	eq(get_lines(), { "a", "b", "c", "d" })
	eq(child.api.nvim_get_mode().mode, "V")
end

T["gY warns when the buffer has no file"] = function()
	local notes = child.lua([[
		local notes = {}
		vim.notify = function(msg, level) table.insert(notes, { msg = msg, level = level }) end
		vim.api.nvim_feedkeys("gY", "x", false)
		return notes
	]])

	eq(notes, { { msg = "No file to copy path from", level = vim.log.levels.WARN } })
end

return T
