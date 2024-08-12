return {
	"nvim-neotest/neotest",
	lazy = true,
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",

		-- adapters
		"olimorris/neotest-phpunit",
	},
	init = function()
		local neotest = require("neotest")

		vim.keymap.set("n", "<leader>rt", neotest.run.run, {})
	end,
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-phpunit"),
			},
		})
	end,
}
