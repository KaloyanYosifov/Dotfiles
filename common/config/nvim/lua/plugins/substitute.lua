return {
	{
		"gbprod/substitute.nvim",
		init = function()
			vim.keymap.set("n", "gr", require("substitute").operator, { noremap = true })
			vim.keymap.set("n", "grr", require("substitute").line, { noremap = true })
			vim.keymap.set("x", "gr", require("substitute").visual, { noremap = true })
		end,
	},
}
