return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	-- focus
	{
		"nvim-focus/focus.nvim",
		version = false,
		init = function()
			require("focus").setup()
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
