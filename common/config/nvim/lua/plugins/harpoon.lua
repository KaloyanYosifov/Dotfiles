return {
	{
		"ThePrimeagen/harpoon",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			{
				"<leader>ha",
				function()
					require("harpoon.mark").toggle_file()
				end,
				desc = "Harpoon: Toggle file",
			},
			{ "<leader>hh", "<cmd>Telescope harpoon marks<cr>", desc = "Harpoon: Marks" },
			{
				"<leader>hn",
				function()
					require("harpoon.ui").nav_next()
				end,
				desc = "Harpoon: Next mark",
			},
			{
				"<leader>hb",
				function()
					require("harpoon.ui").nav_prev()
				end,
				desc = "Harpoon: Previous mark",
			},
		},
		config = function(_, opts)
			require("harpoon").setup(opts)
			require("telescope").load_extension("harpoon")
		end,
		opts = {},
	},
}
