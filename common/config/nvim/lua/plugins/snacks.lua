return {
	{
		"folke/snacks.nvim",
		version = "v2.30.x",
		dependencies = {
			{ "phpactor/phpactor" },
		},
		keys = {
			{
				"<leader>sp",
				":lua require('snacks').scratch()<CR>",
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>sl",
				":lua require('snacks').scratch.select()<CR>",
				desc = "Select Scratch Buffer",
			},
		},
		opts = {
			input = {
				enabled = true,
			},
			notifier = {
				enabled = true,
			},
			indent = {
				enabled = true,
			},
			rename = {
				enabled = true,
				-- This function runs whenever a rename is initiated via Snacks
				on_rename_file = function(old_path, new_path)
					-- Check if it's a PHP file
					if old_path:match("%.php$") then
						-- We delay the command slightly to ensure the file is physically moved
						vim.schedule(function()
							vim.cmd("PhpactorMoveFile " .. old_path .. " " .. new_path)

							vim.notify("Phpactor: Refactoring " .. vim.fn.fnamemodify(new_path, ":t"))
						end)
					end
				end,
			},
			scratch = {
				enabled = true,
			},
		},
	},
}
