return {
	{
		"rmagatti/auto-session",

		lazy = false,

		keys = {
			{ "<leader>sr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
		},

		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			enabled = false,
			auto_save = false,
			suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "/" },
		},
	},
}
