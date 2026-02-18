return {
	-- functionality
	"numToStr/Comment.nvim",

	{
		"kylechui/nvim-surround",
		version = "3.1.8",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},

	-- focus
	{
		"nvim-focus/focus.nvim",
		opts = {},
	},

	-- git
	{
		"sindrets/diffview.nvim",
		keys = {
			{ "<leader>gdf", ":DiffviewFileHistory %<CR>", desc = "Git: DiffView close" },
			{ "<leader>gdc", ":DiffviewClose<CR>", desc = "Git: DiffView close" },
		},
		opts = {},
	},
	{
		"lewis6991/gitsigns.nvim",
		version = "v2.x",
		event = "BufReadPre",
		keys = {
			{ "<leader>gb", ":Gitsigns blame<CR>", desc = "Gitsigns blame" },
		},
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "-" },
				topdelete = { text = "_" },
				changedelete = { text = "~" },
			},
		},
	},

	-- custom
	{
		"my-config/crypt",
		dev = true,
		virtual = true,
		main = "my-config/crypt",
		opts = {},
	},

	{
		"my-config/tabs",
		dev = true,
		virtual = true,
		main = "my-config/tabs",
		keys = {
			{ "<leader>pt", ":lua require('my-config/tabs').go_to_previous()<cr>", desc = "Telescope: List tabs" },
		},
		opts = {},
	},

	-- other
	{ "windwp/nvim-autopairs", opts = {} },
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},
}
