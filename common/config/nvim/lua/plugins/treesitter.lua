local ensure_installed = {
	"css",
	"vimdoc",
	"javascript",
	"jsdoc",
	"typescript",
	"vue",
	"php",
	"phpdoc",
	"c",
	"lua",
	"rust",
	"dockerfile",
	"terraform",
	"scss",
	"toml",
	"json",
	"json5",
	"yaml",
	"python",
	"go",
	"blade",
	"markdown",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		-- The master branch is frozen and does not support Neovim 0.12+.
		-- @see https://github.com/nvim-treesitter/nvim-treesitter/issues/8424#issuecomment-3744851561
		-- @see https://github.com/nvim-treesitter/nvim-treesitter/issues/4767
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		cmd = { "TSUpdate", "TSInstall" },
		config = function()
			vim.filetype.add({
				pattern = {
					[".*%.blade%.php"] = "blade",
				},
			})

			require("nvim-treesitter").install(ensure_installed)

			-- The main branch dropped the module framework, so highlighting and
			-- indentation are enabled per-buffer once a parser is available.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf = args.buf
					local ft = vim.bo[buf].filetype
					local lang = vim.treesitter.language.get_lang(ft) or ft

					local ok, added = pcall(vim.treesitter.language.add, lang)
					if not ok or not added then
						return
					end

					vim.treesitter.start(buf, lang)
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
}
