return {
	{
		"mbbill/undotree",

		init = function()
			vim.g.undotree_SplitWidth = 40
			vim.g.undotree_SetFocusWhenToggle = 1

			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
		end,
	},
}
