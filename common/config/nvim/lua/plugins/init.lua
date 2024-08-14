return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	-- editor
	{
		"ms-jpq/chadtree",
		build = "python3 -m chadtree deps",
		init = function()
			vim.keymap.set("n", "<leader>nd", ":CHADopen<cr>")
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
