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
		version = "v1.0.0",
		opts = {},
	},

	-- git
	{ "rhysd/git-messenger.vim" },
	{
		"f-person/git-blame.nvim",
		init = function()
			vim.keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>")
		end,
		config = function()
			require("gitblame").setup({
				enabled = false,
				schedule_event = "CursorHold",
				clear_event = "CursorHoldI",
			})
		end,
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
	"gpanders/editorconfig.nvim",
	{ "windwp/nvim-autopairs", opts = {} },
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},
}
