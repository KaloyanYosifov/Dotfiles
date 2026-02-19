return {
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
		end,
	},

	-- {
	-- 	"kndndrj/nvim-dbee",
	-- 	dependencies = {
	-- 		"MunifTanjim/nui.nvim",
	-- 	},
	-- 	opts = {},
	-- 	keys = {
	-- 		{ "<leader>dd", ":lua require('dbee').toggle()<cr>", { desc = "Database: toggle" } },
	-- 	},
	-- 	build = function()
	-- 		require("dbee").install()
	-- 	end,
	-- 	config = function()
	-- 		require("dbee").setup({
	-- 			sources = {
	-- 				require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
	-- 			},
	-- 		})
	--
	-- 		vim.api.nvim_create_autocmd({ "FileType" }, {
	-- 			desc = "On buffer enter with file type sql",
	-- 			group = vim.api.nvim_create_augroup("dbee", { clear = true }),
	-- 			pattern = { "sql" },
	-- 			callback = function()
	-- 				vim.keymap.set({ "n" }, "<leader>de", function()
	-- 					local query = utils.get_sql_at_current_cursor()
	-- 					local command = string.format("Dbee execute %s", query)
	-- 					vim.api.nvim_command(command)
	-- 				end, { desc = "[D]bee [e]xecute query under cursor" })
	-- 			end,
	-- 		})
	-- 	end,
	-- },
}
