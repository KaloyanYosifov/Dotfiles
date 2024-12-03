return {
	{
		"nvim-tree/nvim-tree.lua",
		opts = {
			update_focused_file = {
				enable = true,
			},

			on_attach = function(bufnr)
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end
				local api = require("nvim-tree.api")

				api.config.mappings.default_on_attach(bufnr)
				vim.keymap.set("n", "<CR>", api.node.open.tab, opts("Open"))
				vim.keymap.set("n", "e", api.node.open.tab, opts("Open"))
			end,
		},
		init = function()
			vim.keymap.set("n", "<leader>nd", function()
				vim.cmd("NvimTreeToggle")
				require("focus").resize("autoresize")
			end)
		end,
	},
}
