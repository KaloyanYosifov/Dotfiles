return {
	-- functionality
	"tpope/vim-surround",
	"tpope/vim-commentary",

	-- focus
	{
		"nvim-focus/focus.nvim",
		version = false,
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
