local M = {}

M.root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
M.minimal_init = M.root .. "/tests/minimal_init.lua"
M.eq = MiniTest.expect.equality
M.neq = MiniTest.expect.no_equality

--- Test set whose cases each run in a fresh child Neovim with only this config's lua/ on the rtp
---@param child table from MiniTest.new_child_neovim()
---@param hooks? table extra hooks: pre_restart runs before the child restarts, pre_case after
function M.new_set(child, hooks)
	hooks = hooks or {}

	return MiniTest.new_set({
		hooks = {
			pre_once = hooks.pre_once,
			pre_case = function()
				if hooks.pre_restart then
					hooks.pre_restart()
				end

				child.restart({ "-u", M.minimal_init })

				if hooks.pre_case then
					hooks.pre_case()
				end
			end,
			post_case = hooks.post_case,
			post_once = child.stop,
		},
	})
end

function M.tempdir()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")

	return dir
end

function M.write_file(path, content)
	local f = assert(io.open(path, "wb"))
	f:write(content)
	f:close()
end

function M.read_file(path)
	local f = io.open(path, "rb")
	if f == nil then
		return nil
	end

	local content = f:read("*a")
	f:close()

	return content
end

return M
