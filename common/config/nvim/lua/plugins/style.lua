return {
	"Yggdroot/indentLine",
	"nvim-tree/nvim-web-devicons",
	{
		"navarasu/onedark.nvim",

		init = function()
			vim.opt.background = "light"
			vim.cmd.colorscheme("onedark")
		end,

        opts = {}
	},
	{
		"nvim-lualine/lualine.nvim",

		opts = {
			options = {
				theme = "onedark",
			},
		},
	},
}
