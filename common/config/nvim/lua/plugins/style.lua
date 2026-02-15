return {
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
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
}
