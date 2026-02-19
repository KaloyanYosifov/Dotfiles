local utils = require("my-config.utils")

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "jay-babu/mason-nvim-dap.nvim" },
		},
		keys = {
			{ "<leader>db", ":lua require('dap').toggle_breakpoint()<cr>", desc = "Debug: Toggle breakpoint" },
			{ "<leader>dc", ":lua require('dap').continue()<cr>", desc = "Debug: Continue debug or start" },
			{ "<leader>di", ":lua require('dap').step_into()<cr>", desc = "Debug: Step into" },
			{ "<leader>do", ":lua require('dap').step_out()<cr>", desc = "Debug: Step OUt" },
			{ "<leader>dso", ":lua require('dap').step_over()<cr>", desc = "Debug: Step Over" },
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()

					utils.focus_window_on_filetype("dap-repl", { insert_mode = true })
				end,
				desc = "Debug: REPL",
			},
			{ "<leader>dk", ":lua require('dap.ui.widgets').hover()<cr>", desc = "Debug: REPL" },
		},
		config = function()
			require("mason-nvim-dap").setup({
				automatic_installation = true,
				ensure_installed = { "php", "delve" },
			})

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
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "nvim-neotest/nvim-nio" },
		lazy = true,
		keys = {
			{
				"<leader>dt",
				function()
					require("dapui").toggle()
				end,
				desc = "Debug: Toggle breakpoint",
			},
		},
		opts = {},
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		opts = {},
	},
}
