local utils = require("my-config.utils")
local data_path = vim.fn.stdpath("data")
local non_mason_debuggers = {
	php = {
		url = "https://github.com/xdebug/vscode-php-debug/releases/download/v1.35.0/php-debug-1.35.0.vsix",
		path = data_path .. "/php-debugger",
	},
}

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "jay-babu/mason-nvim-dap.nvim" },
		},
		init = function()
			local dap = require("dap")
			local dap_configuration_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }

			local function init_project_config()
				if not pcall(require, "dap") then
					vim.notify(
						"[nvim-dap-projects] Could not find nvim-dap, make sure you load it before nvim-dap-projects.",
						vim.log.levels.ERROR,
						nil
					)

					return
				end

				local project_config = ""
				for _, path in ipairs(dap_configuration_paths) do
					local f = io.open(path)

					if f ~= nil then
						f:close()

						project_config = path

						break
					end
				end

				if project_config == "" then
					return
				end

				vim.notify(
					"[nvim-dap-projects] Found nvim-dap configuration at." .. project_config,
					vim.log.levels.INFO,
					nil
				)

				dap.adapters = (function()
					return {
						lldb = {
							type = "executable",
							command = utils.command_path(
								"lldb-dap",
								"/Library/Developer/CommandLineTools/usr/bin/lldb-dap"
							),
							name = "lldb",
						},
						php = {
							type = "executable",
							command = "node",
							args = { vim.fn.stdpath("data") .. "/debuggers/php/out/phpDebug.js" },
						},
					}
				end)()
				dap.configurations = (function()
					return {}
				end)()

				vim.cmd(":luafile " .. project_config)
			end

			init_project_config()

			-- map K to hover
			local api = vim.api
			local keymap_restore = {}
			dap.listeners.after["event_initialized"]["me"] = function()
				api.nvim_set_keymap(
					"n",
					"<leader>dh",
					'<Cmd>lua require("dap.ui.widgets").hover()<CR>',
					{ silent = true }
				)
			end

			dap.listeners.after["event_terminated"]["me"] = function()
				for _, keymap in pairs(keymap_restore) do
					api.nvim_buf_set_keymap(
						keymap.buffer,
						keymap.mode,
						keymap.lhs,
						keymap.rhs,
						{ silent = keymap.silent == 1 }
					)
				end
				keymap_restore = {}
			end

			-- Mappings
			vim.keymap.set("n", "<leader>rb", ":lua require('dap').toggle_breakpoint()<cr>")
			vim.keymap.set("n", "<leader>dc", ":lua require('dap').continue()<cr>")
			vim.keymap.set("n", "<leader>di", ":lua require('dap').step_into()<cr>")
			vim.keymap.set("n", "<leader>do", ":lua require('dap').step_over()<cr>")
		end,

		config = function()
			local dap_adapters_to_install = {}

			require("mason-nvim-dap").setup({
				automatic_installation = true,
				ensure_installed = dap_adapters_to_install,
			})

			-- Finish up
			-- for key, config in pairs(non_mason_debuggers) do

			-- end
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
		init = function()
			vim.keymap.set("n", "<leader>dk", function()
				require("dapui").toggle()
			end)
		end,
		opts = {},
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		opts = {},
	},
}
