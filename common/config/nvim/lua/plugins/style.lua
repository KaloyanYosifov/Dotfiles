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
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 4,
					},
				},
				lualine_x = { "encoding", "filetype" },
				lualine_y = { "searchcount" },
				lualine_z = { "location" },
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
