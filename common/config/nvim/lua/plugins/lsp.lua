local utils = require("my-config.utils")
local telescope_builtin = require("telescope.builtin")
local debug_mode = utils.get_env("NVIM_LSP_DEBUG", "0") == "1"

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

	vim.lsp.util.jump_to_location(result, "utf-8", true)
end

local function js_eco_system_formatter(parser)
	local package_json = require("lspconfig").util.root_pattern("package.json")
	local path = package_json(vim.fn.getcwd())

	if path == nil then
		return nil
	end

	local prettier_bin_path = path .. "/node_modules/.bin/prettier"
	if utils.file_exists(prettier_bin_path) then
		return require("formatter.defaults.prettier")(parser)
	end

	local util = require("formatter.util")
	local eslint_bin_path = path .. "/node_modules/.bin/eslint"
	if utils.file_exists(eslint_bin_path) then
		return {
			exe = eslint_bin_path,
			args = {
				"--stdin-filename",
				util.escape_path(util.get_current_buffer_file_path()),
				"--fix",
				"--cache",
			},
			stdin = false,
			try_node_modules = true,
		}
	end

	return nil
end

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
		"mhartington/formatter.nvim",
		init = function()
			local augroup_name = "__lsp_formatter__"
			vim.api.nvim_create_augroup(augroup_name, { clear = true })
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = augroup_name,
				command = ":FormatWriteLock",
			})
		end,
		config = function()
			require("formatter").setup({
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

					javascript = js_eco_system_formatter,
					typescript = js_eco_system_formatter,
					typescriptreact = js_eco_system_formatter,
					javascriptreact = js_eco_system_formatter,
					vue = js_eco_system_formatter,

					rust = require("formatter.filetypes.rust").rustfmt,

					go = require("formatter.filetypes.go").gofmt,

					["*"] = require("formatter.filetypes.any").remove_trailing_whitespace,
				},
			})
		end,
	},
	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "L3MON4D3/LuaSnip" },
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
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
			{ "williamboman/mason-lspconfig.nvim" },
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

			local lsps_to_install = {
				"rust_analyzer",
				"lua_ls",
				"jsonls",
				"yamlls",
				"tailwindcss",
				"ts_ls",
				"volar",
				"bashls",
                "gopls",
			}

			if utils.command_exists("composer") then
				table.insert(lsps_to_install, "phpactor")
			end

			require("mason-lspconfig").setup({
				automatic_installation = true,
				ensure_installed = lsps_to_install,
				handlers = {
					function(server_name)
						local config = {}
						local mason_registry = require("mason-registry")

						if server_name == "ts_ls" then
							local vue_language_server_path = mason_registry
								.get_package("vue-language-server")
								:get_install_path() .. "/node_modules/@vue/language-server"
							local tsserver_exec_path = mason_registry
								.get_package("typescript-language-server")
								:get_install_path() .. "/node_modules/typescript/lib/tsserver.js"

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
					end,
				},
			})

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
