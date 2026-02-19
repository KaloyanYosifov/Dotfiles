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
		event = { "BufReadPost", "BufNewFile" },
		lazy = true,
		opts = {
			enable = true,
			commands = true,
			split = {
				bufnew = false,
				tmux = false,
			},
			autoresize = {
				enable = true,
			},
			ui = {
				number = false,
				relativenumber = false,
				hybridnumber = false,
				absolutenumber_unfocussed = false,

				cursorline = false,
				cursorcolumn = false,
				colorcolumn = {
					enable = false,
				},
				signcolumn = false,
				winhighlight = false,
			},
		},
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
	{
		"windwp/nvim-autopairs",
		event = { "InsertEnter", "BufReadPre", "CmdlineEnter" },
		opts = {
			check_ts = true,
			ts_config = {
				lua = { "string", "source" },
				javascript = { "string", "template_string" },
			},
			disable_filetype = { "TelescopePrompt", "spectre_panel", "guihua", "guihua_rust", "clap_input" },
			fast_wrap = {
				map = "<M-e>",
				chars = { "{", "[", "(", '"', "'" },
				pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
				offset = 0, -- Offset from pattern match
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "PmenuSel",
				highlight_grey = "LineNr",
			},
		},
	},
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},
}
