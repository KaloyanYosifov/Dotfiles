local utils = require("my-config.utils")

return {
	{
		"nvim-tree/nvim-tree.lua",
		version = "v1.x",
		dependencies = {
			{ "folke/snacks.nvim" },
			{ "nvim-focus/focus.nvim" },
		},
		keys = {
			{
				"<leader>nd",
				function()
					vim.cmd("NvimTreeToggle")
					vim.schedule(function()
						require("focus").resize()
					end)
				end,
			},
		},
		opts = {
			update_focused_file = {
				enable = true,
			},

			on_attach = function(bufnr)
				local api = require("nvim-tree.api")
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end
				local function open_tab_and_close()
					api.node.open.tab(nil, { quit_on_open = true })
				end

				local function copy_path_picker()
					local node = api.tree.get_node_under_cursor()

					if not node or not node.absolute_path then
						return
					end

					utils.copy_path_picker(node.absolute_path)
				end

				api.config.mappings.default_on_attach(bufnr)
				vim.keymap.set("n", "<CR>", open_tab_and_close, opts("Open"))
				vim.keymap.set("n", "e", open_tab_and_close, opts("Open"))
				vim.keymap.set("n", "gY", copy_path_picker, opts("Copy path picker"))
			end,
		},
		config = function(_, opts)
			require("nvim-tree").setup(opts)

			local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
			vim.api.nvim_create_autocmd("User", {
				pattern = "NvimTreeSetup",
				callback = function()
					local events = require("nvim-tree.api").events
					events.subscribe(events.Event.NodeRenamed, function(data)
						if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
							data = data
							require("snacks").rename.on_rename_file(data.old_name, data.new_name)
						end
					end)
				end,
			})
		end,
	},
}
