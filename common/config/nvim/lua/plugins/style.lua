return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},
	"nvim-tree/nvim-web-devicons",
	{
		"navarasu/onedark.nvim",
		init = function()
			vim.opt.background = "light"
			vim.cmd.colorscheme("onedark")
		end,
		opts = {},
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				theme = "onedark",
			},
		},
	},

	--- UI
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			select = {
				enabled = false,
			},
		},
	},
}
