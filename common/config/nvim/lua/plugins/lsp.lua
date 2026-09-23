local utils = require("my-config.utils")
local debug_mode = utils.get_env("NVIM_LSP_DEBUG", "0") == "1"

local lsps_to_install = {
	"rust_analyzer",
	"lua_ls",
	"jsonls",
	"yamlls",
	"tailwindcss",
	"vtsls",
	"vue_ls",
	"bashls",
	"gopls",
	"helm_ls",
	"pylsp",
	"cssls",
	"terraformls",
	"ansiblels",
	-- Currently too slow with go to definition
	-- wait for that fix
	--"laravel_ls",
}

if utils.command_exists("composer") then
	table.insert(lsps_to_install, "intelephense")
	table.insert(lsps_to_install, "phpactor")
end

local function js_eco_system_formatter()
	local package_json = require("lspconfig").util.root_pattern("package.json")
	local path = package_json(vim.fn.getcwd())

	if path == nil then
		return nil
	end

	local eslint_bin_path = path .. "/node_modules/.bin/eslint"
	if utils.file_exists(eslint_bin_path) then
		return {
			command = eslint_bin_path,
			args = {
				"--fix",
				"--cache",
				"$FILENAME",
			},
			stdin = false,
		}
	end

	return nil
end

local js_formatters = { "prettierd", "prettier", "custom_js", stop_after_first = true }

return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},

	{
		"mason-org/mason.nvim",
		lazy = false,
		config = true,
	},

	-- Formatter
	{
		"stevearc/conform.nvim",
		version = "v9.x",
		opts = {
			log_level = vim.log.levels.ERROR,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "ruff" },
				rust = { "rustfmt", lsp_format = "fallback" },
				php = { "pint", "php_cs_fixer", stop_after_first = true },
				yaml = { "yamlfmt", "yamlfix", stop_after_first = true },
				json = { "jq" },
				sql = { "sqruff", "sqlfluff", stop_after_first = true },
				terraform = { "terraform_fmt" },
				hcl = { "terragrunt_hclfmt" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				zsh = { "shellcheck" },
				toml = { "taplo" },
				scss = { "stylelint" },
				css = { "stylelint" },
				javascript = js_formatters,
				typescript = js_formatters,
				typescriptreact = js_formatters,
				javascriptreact = js_formatters,
				vue = js_formatters,
			},
			format_after_save = {
				timeout_ms = 10000,
				lsp_format = "fallback",
				async = true,
			},
			formatters = {
				custom_js = js_eco_system_formatter,
				yamlfmt = {
					prepend_args = {
						"-formatter",
						"type=basic,retain_line_breaks_single=true,drop_merge_tag=true,indentless_arrays=true",
					},
				},
			},
		},
	},
	-- Autocompletion
	{
		"saghen/blink.cmp",
		version = "1.*",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		---@module "blink.cmp"
		---@type blink.cmp.Config
		opts = {
			enabled = function()
				if vim.api.nvim_get_mode().mode == "c" then
					return true
				end

				if vim.bo.buftype == "prompt" or vim.fn.reg_recording() ~= "" or vim.fn.reg_executing() ~= "" then
					return false
				end

				for _, capture in ipairs(vim.treesitter.get_captures_at_cursor(0)) do
					if capture:find("comment") then
						return false
					end
				end

				local cursor = vim.api.nvim_win_get_cursor(0)
				local syntax_id = vim.fn.synIDtrans(vim.fn.synID(cursor[1], cursor[2], 1))

				return vim.fn.synIDattr(syntax_id, "name") ~= "Comment"
			end,
			keymap = {
				preset = "none",
				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-n>"] = { "select_next", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "accept", "fallback" },
				["<C-y>"] = { "accept", "fallback" },
				["<C-e>"] = { "hide", "fallback" },
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			},
			completion = {
				list = {
					selection = { preselect = true, auto_insert = false },
				},
				accept = {
					auto_brackets = { enabled = true },
				},
				documentation = {
					auto_show = true,
				},
			},
			signature = {
				enabled = true,
			},
			sources = {
				default = { "lsp" },
				per_filetype = {
					lua = { inherit_defaults = true, "lazydev" },
					sql = { "dadbod" },
					mysql = { "dadbod" },
					plsql = { "dadbod" },
				},
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
					dadbod = {
						name = "Dadbod",
						module = "vim_dadbod_completion.blink",
					},
				},
			},
			cmdline = {
				keymap = {
					preset = "cmdline",
					["<C-j>"] = { "select_next", "fallback" },
					["<C-k>"] = { "select_prev", "fallback" },
				},
				completion = {
					menu = { auto_show = true },
				},
			},
		},
	},

	-- Dedicated LSP
	-- {
	-- 	{
	-- 		"gbprod/phpactor.nvim",
	-- 		ft = "php",
	-- 		dependencies = {
	-- 			"nvim-lua/plenary.nvim",
	-- 			"folke/noice.nvim",
	-- 		},
	-- 		opts = {
	-- 			lspconfig = {
	-- 				enabled = false,
	-- 			},
	-- 			-- you're options goes here
	-- 		},
	-- 	},
	-- },

	-- LSP
	{
		"neovim/nvim-lspconfig",
		version = "v2.x",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "saghen/blink.cmp" },
			{
				"mason-org/mason-lspconfig.nvim",
				version = "v2.x",
				opts = {
					automatic_installation = true,
					ensure_installed = lsps_to_install,
				},
			},
			{ "folke/snacks.nvim" },
		},
		config = function()
			if debug_mode then
				vim.lsp.set_log_level("debug")
			end

			vim.diagnostic.config({
				virtual_text = true,
				underline = true,
				severity_sort = true,
				update_in_insert = false,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "✘",
						[vim.diagnostic.severity.WARN] = "▲",
						[vim.diagnostic.severity.INFO] = "»",
						[vim.diagnostic.severity.HINT] = "⚑",
					},
				},
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "<leader>vd", function()
						vim.diagnostic.open_float()
					end, opts)
					vim.keymap.set("n", "gd", function()
						require("telescope.builtin").lsp_definitions({
							jump_type = "tab drop",
							reuse_win = true,
						})
					end, opts)
					vim.keymap.set("n", "gi", function()
						require("telescope.builtin").lsp_implementations({
							jump_type = "tab drop",
							reuse_win = true,
						})
					end, opts)
					vim.keymap.set("n", "gD", function()
						vim.lsp.buf.declaration({
							reuse_win = true,
						})
					end, opts)
					vim.keymap.set("n", "<leader>gr", function()
						require("telescope.builtin").lsp_references({
							jump_type = "tab drop",
							reuse_win = true,
						})
					end, opts)
					vim.keymap.set("n", "<leader>k", function()
						vim.lsp.buf.hover()
					end, opts)
					vim.keymap.set("n", "[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, opts)
					vim.keymap.set("n", "]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, opts)
					vim.keymap.set("n", "<leader>cac", function()
						vim.lsp.buf.code_action()
					end, opts)
					vim.keymap.set("n", "<leader>vre", function()
						vim.lsp.buf.rename()
					end, opts)
					vim.keymap.set("n", "<leader>vrf", function()
						local path = vim.api.nvim_buf_get_name(0)

						if vim.bo.filetype == "php" or path:match("%.php$") then
							vim.cmd("PhpactorMoveFile")

							return
						end

						-- else run snacks
						require("snacks").rename.rename_file()
					end, opts)
					vim.keymap.set("i", "<C-h>", function()
						vim.lsp.buf.signature_help()
					end, opts)
				end,
			})

			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

			-- Temp fix to ignore cancel request from rust-analyzer
			-- @see https://github.com/neovim/neovim/issues/30985
			for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
				local default_diagnostic_handler = vim.lsp.handlers[method]
				vim.lsp.handlers[method] = function(err, result, context, config)
					if err ~= nil and err.code == -32802 then
						return
					end
					return default_diagnostic_handler(err, result, context, config)
				end
			end
		end,
	},
}
