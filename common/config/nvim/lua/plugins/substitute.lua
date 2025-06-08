return {
	{
		"gbprod/substitute.nvim",
		init = function()
			-- remove all keymaps starting with gr
			-- I do not use them unless for substitue plugin
			for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
				if map.lhs:sub(1, 2) == "gr" then
					vim.keymap.del(map.mode, map.lhsraw)
				end
			end

			vim.keymap.set("n", "gr", require("substitute").operator, { noremap = true })
			vim.keymap.set("n", "grr", require("substitute").line, { noremap = true })
			vim.keymap.set("x", "gr", require("substitute").visual, { noremap = true })
		end,
		opts = {},
	},
}
