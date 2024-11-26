return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	-- editor
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

				vim.keymap.set("n", "e", api.node.open.edit, opts("Open"))
			end,
		},
		init = function()
			vim.keymap.set("n", "<leader>nd", ":NvimTreeToggle<cr>")
		end,
	},

	-- custom
	{
		"my-config/crypt",
		dev = true,
		main = "my-config/crypt",
		opts = {},
	},

	-- other
	"gpanders/editorconfig.nvim",
	{
		"windwp/nvim-autopairs",
		opts = {},
	},
}
