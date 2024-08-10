return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	{ "ms-jpq/chadtree", build = "python3 -m chadtree deps" },

	-- databases

	-- other
	{ "my-config/crypt", dev = true },
	"windwp/nvim-autopairs",
	"gpanders/editorconfig.nvim",
	"vimwiki/vimwiki",
	"MunifTanjim/nui.nvim",
}
