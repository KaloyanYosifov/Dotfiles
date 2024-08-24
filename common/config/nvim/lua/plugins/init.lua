return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	-- editor
	{
		"nvim-tree/nvim-tree.lua",
		opts = {
            update_focused_file = {
                enable = true
            }
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
