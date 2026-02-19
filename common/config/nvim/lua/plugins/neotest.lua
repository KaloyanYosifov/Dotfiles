local utils = require("my-config.utils")

return {
	"nvim-neotest/neotest",
	lazy = true,
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",

		-- adapters
		"olimorris/neotest-phpunit",
		"rouge8/neotest-rust",
		"nvim-neotest/neotest-jest",
	},
	keys = {
		{ "<leader>rt", ":lua require('neotest').run.run()<cr>", desc = "Test: Run" },
		{
			"<leader>rs",
			function()
				require("neotest").output_panel.toggle()

				utils.focus_window_on_filetype("neotest-output-panel")
			end,
			desc = "Test: Toggle panel",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				-- rust
				require("neotest-rust"),

				-- php
				require("neotest-phpunit")({
					phpunit_cmd = function()
						local phpunit_container = utils.get_env("NEOTEST_PHPUNIT_CONTAINER", nil)

						if phpunit_container == nil then
							return utils.get_env("VIM_PHPUNIT_TEST_CMD", "vendor/bin/phpunit")
						end

						return vim.fn.stdpath("config") .. "/scripts/phpunit-in-docker.sh"
					end,
				}),

				-- javascript
				require("neotest-jest")({
					jestCommand = function()
						return utils.get_env("VIM_JEST_TEST_CMD", "node_modules/.bin/jest")
					end,
					jestConfigFile = "jest.config.js",
					cwd = function()
						return vim.fn.getcwd()
					end,
				}),
			},
		})
	end,
}
