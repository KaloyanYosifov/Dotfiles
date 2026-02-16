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
	{ "rhysd/git-messenger.vim" },
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

	-- other
	{ "windwp/nvim-autopairs", opts = {} },
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},
}
