return {
	{
		"rmagatti/auto-session",

		lazy = false,

		keys = {
			{ "<leader>sr", "<cmd>AutoSession restore<cr>", desc = "Restore session" },
		},

		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			enabled = true,
			auto_save = true,
			auto_restore = false,
			suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "/" },
			git_use_branch_name = true,
			git_auto_restore_on_branch_change = true,
		},
	},
}
