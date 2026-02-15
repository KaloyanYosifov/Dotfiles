return {
	{
		"folke/snacks.nvim",
		version = "v2.30.x",
		keys = {
			{
				"<leader>sn",
				":lua require('snacks').scratch()<CR>",
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>sl",
				":lua require('snacks').scratch.select()<CR>",
				desc = "Select Scratch Buffer",
			},
		},
		opts = {
			input = {
				enabled = true,
			},
			notifier = {
				enabled = true,
			},
			indent = {
				enabled = true,
			},
			rename = {
				enabled = true,
			},
			scratch = {
				enabled = true,
			},
		},
	},
}
