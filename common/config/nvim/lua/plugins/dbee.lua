return {
	{
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
        build = function()
            require("dbee").install()
        end,
		init = function()
			local dbee = require("dbee")

			-- Keymaps
			vim.keymap.set("n", "<leader>db", dbee.toggle)
		end,
        opts = {}
	},
}
