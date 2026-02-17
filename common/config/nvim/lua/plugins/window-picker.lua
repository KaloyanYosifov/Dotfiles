return {
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		keys = {
			{
				"<leader>w",
				function()
					local picked_id = require("window-picker").pick_window()
					if picked_id then
						vim.api.nvim_set_current_win(picked_id)
					end
				end,
				{ desc = "Window picker: pick window" },
			},
		},
		opts = {
			hint = "floating-big-letter",
			show_prompt = false,
		},
	},
}
