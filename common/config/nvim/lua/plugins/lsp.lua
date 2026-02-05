local utils = require("my-config.utils")
local telescope_builtin = require("telescope.builtin")
local debug_mode = utils.get_env("NVIM_LSP_DEBUG", "0") == "1"

local lsps_to_install = {
	"rust_analyzer",
	"lua_ls",
	"jsonls",
	"yamlls",
	"tailwindcss",
	"ts_ls",
	"vue_ls",
	"bashls",
	"gopls",
	"helm_ls",
	"pylsp",
}

if utils.command_exists("composer") then
	table.insert(lsps_to_install, "phpactor")
end

local function open_lsp_location_in_new_tab(_, result, ctx, _)
	if not result or vim.tbl_isempty(result) then
		print("No location found for " .. ctx.method)
		return
	end

	if vim.islist(result) then
		result = result[1]
	end

	if not utils.is_buffer_uri_already_open(result.uri or result.targetUri) then
		vim.cmd("tabnew")
	end

	vim.lsp.util.show_document(result, "utf-8", { focus = true })
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

local js_formatters = { "custom_js", "prettierd", "prettier", stop_after_first = true }

return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {},
	},

	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v4.x",
		lazy = false,
		config = false,
	},
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = true,
	},
	-- Formatter
	{
		"stevearc/conform.nvim",
		opts = {
			log_level = vim.log.levels.ERROR,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "ruff" },
				rust = { "rustfmt", lsp_format = "fallback" },
				php = { "pint", "php-cs-fixer", stop_after_first = true },
				yaml = { "yamlfmt", "yamlfix", stop_after_first = true },
				json = { "jsonnetfmt" },
				javascript = js_formatters,
				typescript = js_formatters,
				typescriptreact = js_formatters,
				javascriptreact = js_formatters,
				vue = js_formatters,
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 10000,
				lsp_format = "fallback",
			},
			formatters = {
				custom_js = js_eco_system_formatter,
				yamlfmt = {
					prepend_args = { "-formatter", "retain_line_breaks_single=true" },
				},
			},
		},
	},
	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
		},
		config = function()
			local cmp = require("cmp")
			local cmp_select = { behavior = cmp.SelectBehavior.Select }

			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "lazydev", group_index = 0 },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
					["<S-Tab>"] = nil,
				}),
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			})
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		version = "v1.1.0",
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "williamboman/mason.nvim" },
			{
				"williamboman/mason-lspconfig.nvim",
				opts = {
					automatic_installation = true,
					ensure_installed = lsps_to_install,
				},
			},
		},
		init = function()
			if debug_mode then
				vim.lsp.set_log_level("debug")
			end

			vim.diagnostic.config({
				virtual_text = true,
			})
		end,
		config = function()
			local lsp_zero = require("lsp-zero")

			-- lsp_attach is where you enable features that only work
			-- if there is a language server active in the file
			local lsp_attach = function(_, bufnr)
				local opts = { buffer = bufnr, remap = false }

				-- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)

				vim.keymap.set("n", "<leader>vd", function()
					vim.diagnostic.open_float()
				end, opts)
				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, opts)
				vim.keymap.set("n", "gi", function()
					vim.lsp.buf.implementation()
				end, opts)
				vim.keymap.set("n", "gD", function()
					vim.lsp.buf.declaration()
				end, opts)
				vim.keymap.set("n", "<leader>gr", function()
					telescope_builtin.lsp_references()
				end, opts)
				vim.keymap.set("n", "<leader>k", function()
					vim.lsp.buf.hover()
				end, opts)
				vim.keymap.set("n", "[d", function()
					vim.diagnostic.goto_next()
				end, opts)
				vim.keymap.set("n", "]d", function()
					vim.diagnostic.goto_prev()
				end, opts)
				vim.keymap.set("n", "<leader>cac", function()
					vim.lsp.buf.code_action()
				end, opts)
				vim.keymap.set("n", "<leader>vre", function()
					vim.lsp.buf.rename()
				end, opts)
				vim.keymap.set("i", "<C-h>", function()
					vim.lsp.buf.signature_help()
				end, opts)
			end

			lsp_zero.extend_lspconfig({
				sign_text = true,
				lsp_attach = lsp_attach,
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
			lsp_zero.set_sign_icons({
				error = "✘",
				warn = "▲",
				hint = "⚑",
				info = "»",
			})

			for _, server_name in ipairs(lsps_to_install) do
				local config = {}

				if server_name == "ts_ls" then
					local vue_language_server_path = vim.fn.expand("$MASON/packages/vue-language-server")
						.. "/node_modules/@vue/language-server"
					local tsserver_exec_path = vim.fn.expand("$MASON/packages/typescript-language-server")
						.. "/node_modules/typescript/lib/tsserver.js"

					config = {
						init_options = {
							tsserver = {
								path = tsserver_exec_path,
							},
							plugins = {
								{
									name = "@vue/typescript-plugin",
									location = vue_language_server_path,
									languages = { "vue" },
								},
							},
							preferences = {
								includeInlayParameterNameHints = "literals",
								includeInlayVariableTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						filetypes = {
							"vue",
							"javascript",
							"javascriptreact",
							"javascript.jsx",
							"typescript",
							"typescriptreact",
							"typescript.tsx",
						},
					}

					if debug_mode then
						config.init_options.tsserver.logVerbosity = "verbose"
						config.cmd = { "typescript-language-server", "--stdio", "--log-level", "4" }
					end
				end

				require("lspconfig")[server_name].setup(config)
			end

			vim.lsp.handlers["textDocument/definition"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/references"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/implementation"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/declaration"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/typeDefinition"] = open_lsp_location_in_new_tab

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
