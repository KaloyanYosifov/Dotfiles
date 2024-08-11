return {
	"LukasPietzschmann/telescope-tabs",
	dependencies = { "nvim-telescope/telescope.nvim" },
	opts = {},
	init = function()
		local telescope_tabs = require("telescope-tabs")

		vim.keymap.set("n", "<leader>pt", telescope_tabs.list_tabs, {})
	end,
	config = function(_, opts)
		require("telescope").load_extension("telescope-tabs")
		require("telescope-tabs").setup(opts)
	end,
}
