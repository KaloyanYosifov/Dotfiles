return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	-- editor
	{ "ms-jpq/chadtree", build = "python3 -m chadtree deps" },

	-- custom
	{ "my-config/crypt", dev = true },

	-- other
	"vimwiki/vimwiki",
	"windwp/nvim-autopairs",
	"gpanders/editorconfig.nvim",
	"MunifTanjim/nui.nvim",
	"nvim-lua/plenary.nvim",
}