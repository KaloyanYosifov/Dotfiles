return {
	{
		"olimorris/codecompanion.nvim",
		version = "^18.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{ "<leader>aic", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle AI Companion Chat" },
		},

		opts = {
			interactions = {
				chat = {
					adapter = "gemini_cli",
				},
			},
			inline = {
				adapter = "gemini_cli",
			},
			cmd = {
				adapter = "gemini_cli",
			},
			adapters = {
				acp = {
					gemini_cli = function()
						return require("codecompanion.adapters").extend("gemini_cli", {
							defaults = {
								auth_method = "oauth-personal",
							},
						})
					end,
				},
			},
		},
	},
}
