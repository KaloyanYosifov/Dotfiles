-- Checks the lazy.nvim specs in lua/plugins/ without installing any plugin
local helpers = dofile("tests/helpers.lua")
local eq = helpers.eq

local child = MiniTest.new_child_neovim()
local T = helpers.new_set(child)

local spec_files = vim.fn.glob(helpers.root .. "/lua/plugins/*.lua", false, true)

-- Loaded in the test runner itself: specs hold functions, which can't cross RPC from the child.
-- The runner has no plugins on its runtimepath either.
local function load_specs(file)
	return dofile(file)
end

-- Flattens nested spec lists into plugin specs, the way lazy.nvim reads them:
-- a string is a plugin, a table with more than one entry is a list, anything else is a plugin
local function each_plugin(specs, fn)
	if type(specs) == "string" then
		return fn({ specs })
	end

	if #specs > 1 or (vim.islist(specs) and type(specs[1]) ~= "string") then
		for _, spec in ipairs(specs) do
			each_plugin(spec, fn)
		end

		return
	end

	fn(specs)
	for _, dep in ipairs(type(specs.dependencies) == "table" and specs.dependencies or {}) do
		each_plugin(dep, fn)
	end
end

T["every spec file loads without any plugin installed"] = function()
	for _, file in ipairs(spec_files) do
		local ok, err = pcall(load_specs, file)
		if not ok then
			error(vim.fn.fnamemodify(file, ":t") .. ": " .. tostring(err))
		end
	end
end

T["every key mapping passes desc as a field"] = function()
	for _, file in ipairs(spec_files) do
		each_plugin(load_specs(file), function(plugin)
			for _, key in ipairs(type(plugin.keys) == "table" and plugin.keys or {}) do
				-- lazy.nvim ignores a positional options table, so the desc silently disappears
				if type(key) == "table" and type(key[3]) == "table" then
					error(string.format("%s: %s passes a table as keys[3], use desc = ...", plugin[1], key[1]))
				end
			end
		end)
	end
end

T["removed plugins stay removed"] = function()
	local removed = {
		["numToStr/Comment.nvim"] = true,
		["hrsh7th/nvim-cmp"] = true,
		["hrsh7th/cmp-nvim-lsp"] = true,
		["j-hui/fidget.nvim"] = true,
	}

	for _, file in ipairs(spec_files) do
		each_plugin(load_specs(file), function(plugin)
			if removed[plugin[1]] then
				error(string.format("%s is back in %s", plugin[1], vim.fn.fnamemodify(file, ":t")))
			end
		end)
	end
end

T["snacks does not pull in phpactor at startup"] = function()
	each_plugin(load_specs(helpers.root .. "/lua/plugins/snacks.lua"), function(plugin)
		if plugin[1] == "folke/snacks.nvim" then
			eq(plugin.dependencies, nil)
		end
	end)
end

-- blink.cmp's `enabled` rule, taken straight from lua/plugins/lsp.lua
T["blink enabled()"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.lua(
				[[
					for _, spec in ipairs(dofile(...)) do
						if spec[1] == "saghen/blink.cmp" then
							_G.enabled = spec.opts.enabled
						end
					end
				]],
				{ helpers.root .. "/lua/plugins/lsp.lua" }
			)
		end,
	},
})

local function enabled()
	return child.lua("return _G.enabled()")
end

T["blink enabled()"]["is on in normal code"] = function()
	child.api.nvim_buf_set_lines(0, 0, -1, false, { "local x = 1" })
	child.bo.filetype = "lua"
	child.lua("vim.treesitter.start()")
	child.api.nvim_win_set_cursor(0, { 1, 6 })

	eq(enabled(), true)
end

T["blink enabled()"]["is off inside a comment"] = function()
	child.api.nvim_buf_set_lines(0, 0, -1, false, { "-- a comment here" })
	child.bo.filetype = "lua"
	child.lua("vim.treesitter.start()")
	child.api.nvim_win_set_cursor(0, { 1, 8 })

	eq(enabled(), false)
end

T["blink enabled()"]["is off in prompt buffers"] = function()
	child.bo.buftype = "prompt"

	eq(enabled(), false)
end

T["blink enabled()"]["is off while recording a macro"] = function()
	child.type_keys("qq")

	eq(enabled(), false)
end

T["blink enabled()"]["is on in the command line"] = function()
	child.bo.buftype = "prompt"
	child.type_keys(":")

	eq(enabled(), true)
end

return T
