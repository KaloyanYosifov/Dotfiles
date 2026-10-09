-- Smoke tests: boot the real init.lua with the installed plugins in a child Neovim.
-- Skipped when lazy.nvim isn't installed. Run :Lazy sync first.
local helpers = dofile("tests/helpers.lua")
local eq = helpers.eq

local child = MiniTest.new_child_neovim()

if vim.uv.fs_stat(vim.fn.stdpath("data") .. "/lazy/lazy.nvim") == nil then
	local T = MiniTest.new_set()
	T["config"] = function()
		MiniTest.skip("lazy.nvim is not installed, run :Lazy sync first")
	end

	return T
end

-- One child for the whole file: booting every plugin per case would be slow.
-- Cases run in order and the last one loads every plugin.
local T = MiniTest.new_set({
	hooks = {
		pre_once = function()
			-- mini.test starts children with --clean, which leaves the config dir off the runtimepath
			child.start({ "--cmd", "set rtp^=" .. helpers.root, "-u", helpers.root .. "/init.lua" })
			child.fn.chdir(helpers.tempdir())
			-- Keep auto-session from saving a session for the test run
			child.cmd("silent! autocmd! VimLeavePre")
		end,
		post_once = child.stop,
	},
})

local function is_loaded(name)
	return child.lua("return require('lazy.core.config').plugins[...]._.loaded ~= nil", { name })
end

T["starts without errors"] = function()
	eq(child.v.errmsg, "")

	local messages = child.cmd_capture("messages")
	eq(messages:find("E%d+:") == nil and messages:find("Error") == nil, true)
end

T["keeps heavy plugins lazy at startup"] = function()
	for _, name in ipairs({ "telescope.nvim", "phpactor", "blink.cmp", "nvim-dap", "harpoon", "substitute.nvim" }) do
		eq({ name, is_loaded(name) }, { name, false })
	end
end

T["has the key mappings"] = function()
	local mappings = {
		{ "n", ",f" },
		{ "n", ",pf" },
		{ "n", "<C-p>" },
		{ "n", ",w" },
		{ "n", ",u" },
		{ "n", ",nd" },
		{ "n", ",ha" },
		{ "n", ",hh" },
		{ "n", ",db" },
		{ "n", ",dt" },
		{ "n", ",rt" },
		{ "n", ",aic" },
		{ "n", ",pt" },
		{ "n", ",st" },
		{ "n", ",sp" },
		{ "n", ",gb" },
		{ "n", "gr" },
		{ "x", "gr" },
		{ "n", "grr" },
		{ "n", "gY" },
		{ "n", ",y" },
		{ "v", ",y" },
		{ "n", "<S-j>" },
		{ "n", "<S-k>" },
	}

	for _, mapping in ipairs(mappings) do
		eq({ mapping, child.fn.maparg(mapping[2], mapping[1]) ~= "" }, { mapping, true })
	end
end

T["removes the default gr LSP mappings for substitute"] = function()
	for _, lhs in ipairs({ "grn", "gra", "gri" }) do
		eq({ lhs, child.fn.maparg(lhs, "n") }, { lhs, "" })
	end
end

T["uses the built-in comment mappings"] = function()
	child.api.nvim_buf_set_lines(0, 0, -1, false, { "local x = 1" })
	child.bo.filetype = "lua"
	child.type_keys("gcc")

	eq(child.api.nvim_buf_get_lines(0, 0, -1, false), { "-- local x = 1" })
end

T["has the user commands"] = function()
	for _, name in ipairs({ "CryptEncryptFile", "Lazy", "DBUI", "VimwikiIndex" }) do
		eq({ name, child.fn.exists(":" .. name) == 2 }, { name, true })
	end
end

T["LSP"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			-- Run only this config's LspAttach handler, with no real server attached
			child.lua([[
				require("lazy").load({ plugins = { "nvim-lspconfig" } })
				vim.cmd("enew")
				local buf = vim.api.nvim_get_current_buf()
				for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = "LspAttach" })) do
					if autocmd.callback and debug.getinfo(autocmd.callback, "S").source:find("plugins/lsp.lua", 1, true) then
						autocmd.callback({ buf = buf })
					end
				end
			]])
		end,
	},
})

T["LSP"]["sets buffer mappings on attach"] = function()
	for _, lhs in ipairs({ "gd", "gi", "gD", ",gr", ",k", "[d", "]d", ",cac", ",vre", ",vrf", ",vd" }) do
		local buffer = child.lua("return vim.fn.maparg(..., 'n', false, true).buffer", { lhs })
		eq({ lhs, buffer }, { lhs, 1 })
	end
end

T["LSP"]["]d goes to the next diagnostic and [d to the previous"] = function()
	child.lua([[
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "a", "b", "c", "d", "e" })
		local ns = vim.api.nvim_create_namespace("config_test")
		vim.diagnostic.set(ns, 0, {
			{ lnum = 0, col = 0, message = "first", severity = vim.diagnostic.severity.ERROR },
			{ lnum = 4, col = 0, message = "last", severity = vim.diagnostic.severity.ERROR },
		})
		vim.api.nvim_win_set_cursor(0, { 3, 0 })
	]])

	child.type_keys("]d")
	eq(child.api.nvim_win_get_cursor(0)[1], 5)

	child.type_keys("[d")
	eq(child.api.nvim_win_get_cursor(0)[1], 1)
end

T["LSP"]["sorts diagnostics by severity"] = function()
	eq(child.lua_get("vim.diagnostic.config().severity_sort"), true)
end

T["LSP"]["servers get blink's completion capabilities"] = function()
	local snippet_support = child.lua_get(
		"vim.tbl_get(vim.lsp.config['*'], 'capabilities', 'textDocument', 'completion', 'completionItem', 'snippetSupport')"
	)

	eq(snippet_support, true)
end

T["vim.ui.select loads telescope-ui-select on first use"] = function()
	child.lua("vim.ui.select({ 'a' }, {}, function() end)")

	eq(is_loaded("telescope-ui-select.nvim"), true)
	eq(is_loaded("telescope.nvim"), true)
end

T["lualine has the lsp_status component"] = function()
	eq(child.lua_get("pcall(require, 'lualine.components.lsp_status')"), true)
end

T["every plugin loads without errors"] = function()
	local result = child.lua([[
		local errors = {}
		vim.notify = function(msg, level)
			if level == vim.log.levels.ERROR then
				table.insert(errors, msg)
			end
		end

		local plugins = require("lazy.core.config").plugins
		local ok, err = pcall(require("lazy").load, { plugins = vim.tbl_keys(plugins) })
		if not ok then
			table.insert(errors, tostring(err))
		end

		local not_loaded = {}
		for name, plugin in pairs(plugins) do
			if plugin._.loaded == nil then
				table.insert(not_loaded, name)
			end
		end

		return { errors = errors, not_loaded = not_loaded }
	]])

	eq(result, { errors = {}, not_loaded = {} })
end

return T
