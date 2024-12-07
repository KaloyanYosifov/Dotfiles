local utils = require("my-config.utils")

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
		"rouge8/neotest-rust",
		"nvim-neotest/neotest-jest",
	},
	init = function()
		local neotest = require("neotest")

		vim.keymap.set("n", "<leader>rt", neotest.run.run, {})
		vim.keymap.set("n", "<leader>rr", neotest.run.run_last, {})
		vim.keymap.set("n", "<leader>rs", neotest.output_panel.toggle, {})
	end,
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
