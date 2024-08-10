return {
	{
		"ThePrimeagen/harpoon",

		init = function()
			local mark = require("harpoon.mark")
			local ui = require("harpoon.ui")

			require("telescope").load_extension("harpoon")

			vim.keymap.set("n", "<leader>ha", mark.toggle_file)
			vim.keymap.set("n", "<leader>hh", ":Telescope harpoon marks<cr>")

			vim.keymap.set("n", "<leader>hn", ui.nav_next)
			vim.keymap.set("n", "<leader>hb", ui.nav_prev)
		end,

        opts = {}
	},
}
