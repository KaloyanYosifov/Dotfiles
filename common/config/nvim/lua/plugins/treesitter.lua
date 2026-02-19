return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = vim.fn.argc(-1) == 0,
		-- @see https://github.com/nvim-treesitter/nvim-treesitter/issues/8424#issuecomment-3744851561
		-- @see https://github.com/nvim-treesitter/nvim-treesitter/issues/4767
		branch = "master",
		opts = {
			-- A list of parser names, or "all"
			ensure_installed = {
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
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			indent = { enable = true },

			highlight = {
				enable = true,

				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
		},
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		config = function(_, opts)
			vim.filetype.add({
				pattern = {
					[".*%.blade%.php"] = "blade",
				},
			})

			require("nvim-treesitter.configs").setup(opts)
		end,
	},
}
