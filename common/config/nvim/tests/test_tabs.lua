local helpers = dofile("tests/helpers.lua")
local eq = helpers.eq

local child = MiniTest.new_child_neovim()
local T = helpers.new_set(child, {
	pre_case = function()
		-- tabs.lua notifies through snacks, which isn't installed in the unit test child
		child.lua([[
			_G.notes = {}
			package.loaded.snacks = {
				notify = function(msg, opts) table.insert(_G.notes, { msg = msg, level = opts.level }) end,
			}
			require("my-config.tabs").setup()
		]])
	end,
})

local function go_to_previous()
	child.lua("require('my-config.tabs').go_to_previous()")
end

T["goes back to the previous tab"] = function()
	child.cmd("tabnew")
	eq(child.fn.tabpagenr(), 2)

	go_to_previous()
	eq(child.fn.tabpagenr(), 1)
end

T["walks back through tab history"] = function()
	child.cmd("tabnew")
	child.cmd("tabnew")
	child.cmd("tabfirst")

	go_to_previous()
	eq(child.fn.tabpagenr(), 3)
end

T["notifies when there is no previous tab"] = function()
	go_to_previous()

	eq(child.lua_get("_G.notes"), { { msg = "No previous tab to go to", level = "error" } })
end

T["reopens the file of a previous tab that was closed"] = function()
	local file = helpers.tempdir() .. "/closed.txt"
	helpers.write_file(file, "content\n")

	child.cmd("tabnew " .. file)
	child.cmd("tabnew")
	child.cmd("2tabclose")

	go_to_previous()

	eq(child.fn.tabpagenr("$"), 3)
	eq(child.api.nvim_buf_get_name(0), file)
end

return T
