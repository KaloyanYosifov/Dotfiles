return {
	{
		"nvim-tree/nvim-tree.lua",
		version = "v1.x",
		keys = {
			{
				"<leader>nd",
				function()
					vim.cmd("NvimTreeToggle")
					require("focus").resize()
				end,
			},
		},
		opts = {
			update_focused_file = {
				enable = true,
			},

			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end
				local function open_tab_and_close()
					api.node.open.tab(nil, { quit_on_open = true })
				end

				api.config.mappings.default_on_attach(bufnr)
				vim.keymap.set("n", "<CR>", open_tab_and_close, opts("Open"))
				vim.keymap.set("n", "e", open_tab_and_close, opts("Open"))
			end,
		},
	},
}
