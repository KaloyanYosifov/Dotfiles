

return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	-- editor
	{ "ms-jpq/chadtree", build = "python3 -m chadtree deps" },

	-- custom
	{
		"my-config/crypt",
		dev = true,
		config = function()
			require("my-config/crypt").setup()
		end,
	},

	-- other
	"gpanders/editorconfig.nvim",
	{
		"windwp/nvim-autopairs",
		opts = {},
	},
}
