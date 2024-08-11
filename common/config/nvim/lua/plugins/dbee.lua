local utils = require("my-config.utils")

return {
	{
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		pts = {},
		build = function()
			require("dbee").install()
		end,
		init = function()
			local dbee = require("dbee")

			-- Keymaps
			vim.keymap.set("n", "<leader>db", dbee.toggle)

			vim.api.nvim_create_autocmd({ "FileType" }, {
				desc = "On buffer enter with file type sql",
				group = vim.api.nvim_create_augroup("dbee", { clear = true }),
				pattern = { "sql" },
				callback = function()
					vim.keymap.set({ "n" }, "<leader>de", function()
						local query = utils.get_sql_at_current_cursor()
						local command = string.format("Dbee execute %s", query)
						vim.api.nvim_command(command)
					end, { desc = "[D]bee [e]xecute query under cursor" })
				end,
			})
		end,
		config = function()
			require("dbee").setup({
				sources = {
					require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
				},
			})
		end,
	},
}
