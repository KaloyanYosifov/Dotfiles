return {
	{
		"kndndrj/nvim-dbee",

		init = function()
			local dbee = require("dbee")

			-- Keymaps
			vim.keymap.set("n", "<leader>db", dbee.toggle)
		end,
	},
}
