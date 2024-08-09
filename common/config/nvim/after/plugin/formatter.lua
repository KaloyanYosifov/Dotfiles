local formatter = require("formatter")
local utils = require("my-config.utils")

formatter.setup({
	logging = true,

	log_level = vim.log.levels.ERROR,

	filetype = {
		lua = {
			require("formatter.filetypes.lua").stylua,
		},

		php = {
			function()
				local composer_root = require("lspconfig").util.root_pattern("composer.json")
				local path = composer_root(vim.fn.getcwd())

				if path == nil then
					return nil
				end

				local executables = { "pint", "php-cs-fixer" }
				local bin_path = path .. "/vendor/bin/"

				for _, executable in ipairs(executables) do
					local exe = bin_path .. executable

					if utils.file_exists(exe) then
						local opts = {
							exe = exe,
							stdin = false,
							ignore_exitcode = false,
						}

						if executable == "php-cs-fixer" then
							opts.args = { "fix" }
						end

						return opts
					end
				end

				return nil
			end,
		},

		rust = {
			require("formatter.filetypes.rust").rustfmt,
		},

		["*"] = {
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
	},
})

local augroup_name = "__lsp_formatter__"
vim.api.nvim_create_augroup(augroup_name, { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = augroup_name,
	command = ":FormatWrite",
})
