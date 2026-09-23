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
			{ "<leader>do", ":lua require('dap').step_out()<cr>", desc = "Debug: Step out" },
			{ "<leader>dso", ":lua require('dap').step_over()<cr>", desc = "Debug: Step Over" },
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()

					utils.focus_window_on_filetype("dap-repl", { insert_mode = true })
				end,
				desc = "Debug: REPL",
			},
			{ "<leader>dk", ":lua require('dap.ui.widgets').hover()<cr>", desc = "Debug: Hover" },
		},
		config = function()
			require("mason-nvim-dap").setup({
				automatic_installation = true,
				ensure_installed = { "php", "delve" },
			})

			local dap = require("dap")
			local dap_configuration_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }

			local function init_project_config()
				local project_config = nil
				for _, path in ipairs(dap_configuration_paths) do
					if vim.uv.fs_stat(path) then
						project_config = path

						break
					end
				end

				if project_config == nil then
					return
				end

				-- vim.secure.read asks once before trusting a repo's file, so a cloned
				-- project can't run code just because a breakpoint was toggled
				local contents = vim.secure.read(project_config)
				if contents == nil then
					vim.notify("[nvim-dap-projects] Skipped untrusted " .. project_config, vim.log.levels.WARN)

					return
				end

				dap.adapters = vim.tbl_extend("force", dap.adapters, {
					lldb = {
						type = "executable",
						command = utils.command_path("lldb-dap", "/Library/Developer/CommandLineTools/usr/bin/lldb-dap"),
						name = "lldb",
					},
					php = {
						type = "executable",
						command = "node",
						args = { vim.fn.stdpath("data") .. "/debuggers/php/out/phpDebug.js" },
					},
				})

				local chunk, err = load(contents, "@" .. project_config)
				if chunk == nil then
					vim.notify("[nvim-dap-projects] " .. err, vim.log.levels.ERROR)

					return
				end

				chunk()

				vim.notify("[nvim-dap-projects] Loaded " .. project_config, vim.log.levels.INFO)
			end

			init_project_config()

			dap.listeners.after["event_initialized"]["me"] = function()
				vim.keymap.set("n", "<leader>dh", function()
					require("dap.ui.widgets").hover()
				end, { silent = true, desc = "Debug: Hover" })
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
				desc = "Debug: Toggle UI",
			},
		},
		opts = {},
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		opts = {},
	},
}
