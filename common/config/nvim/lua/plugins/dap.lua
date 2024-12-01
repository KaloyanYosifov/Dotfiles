local utils = require("my-config.utils")

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
				for _, buf in pairs(api.nvim_list_bufs()) do
					local keymaps = api.nvim_buf_get_keymap(buf, "n")
					for _, keymap in pairs(keymaps) do
						if keymap.lhs == "K" then
							table.insert(keymap_restore, keymap)
							api.nvim_buf_del_keymap(buf, "n", "K")
						end
					end
				end
				api.nvim_set_keymap("n", "K", '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
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
				ensure_installed = dap_adapters_to_install,
			})
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		init = function()
			local dap_ui = require("dapui")

			dap_ui.setup()

			vim.keymap.set("n", "<leader>dk", ":lua require('dapui').toggle()<cr>")
		end,
	},
}
