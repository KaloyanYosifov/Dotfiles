local helpers = dofile("tests/helpers.lua")
local eq = helpers.eq

local child = MiniTest.new_child_neovim()
local T = helpers.new_set(child)

T["settings"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.lua("require('my-config.settings')")
		end,
	},
})

T["settings"]["sets leader keys"] = function()
	eq(child.g.mapleader, ",")
	eq(child.g.maplocalleader, "\\")
end

T["settings"]["keeps undo history but no swap or backup files"] = function()
	eq(child.o.undofile, true)
	eq(child.o.swapfile, false)
	eq(child.o.backup, false)
	eq(child.o.writebackup, false)
	eq(child.o.undodir, vim.env.HOME .. "/.vim/undodir")
end

T["settings"]["uses 4 space indentation"] = function()
	eq(child.o.expandtab, true)
	eq(child.o.tabstop, 4)
	eq(child.o.shiftwidth, 4)
	eq(child.o.softtabstop, 4)
end

T["settings"]["disables netrw"] = function()
	eq(child.g.loaded_netrw, 1)
	eq(child.g.loaded_netrwPlugin, 1)
end

T["settings"]["opens switched buffers in their existing tab"] = function()
	eq(child.o.switchbuf, "useopen,usetab,newtab")
end

T["autocommands"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.lua("require('my-config.autocommands')")
		end,
	},
})

T["autocommands"]["treats .mdc files as markdown"] = function()
	child.cmd("edit " .. helpers.tempdir() .. "/rules.mdc")

	eq(child.bo.filetype, "markdown")
end

T["autocommands"]["highlights yanks without errors"] = function()
	child.api.nvim_buf_set_lines(0, 0, -1, false, { "yank me" })
	child.type_keys("yy")

	eq(child.v.errmsg, "")
	eq(child.fn.getreg('"'), "yank me\n")
end

return T
