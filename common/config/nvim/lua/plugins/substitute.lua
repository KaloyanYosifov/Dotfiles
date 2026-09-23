return {
	{
		"gbprod/substitute.nvim",
		lazy = true,
		init = function()
			-- remove all keymaps starting with gr
			-- I do not use them unless for substitue plugin
			for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
				if map.lhs:sub(1, 2) == "gr" then
					vim.keymap.del(map.mode, map.lhsraw)
				end
			end

			vim.keymap.set("n", "gr", function()
				require("substitute").operator()
			end, { noremap = true })
			vim.keymap.set("n", "grr", function()
				require("substitute").line()
			end, { noremap = true })
			vim.keymap.set("x", "gr", function()
				require("substitute").visual()
			end, { noremap = true })
		end,
		opts = {},
	},
}
