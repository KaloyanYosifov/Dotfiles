local utils = require("my-config.utils")

local function open_lsp_location_in_new_tab(_, result, ctx, _)
	if not result or vim.tbl_isempty(result) then
		print("No location found for " .. ctx.method)
		return
	end

	if vim.tbl_islist(result) then
		result = result[1]
	end

	if not utils.is_buffer_uri_already_open(result.uri or result.targetUri) then
		vim.cmd("tabnew")
	end

	vim.lsp.util.jump_to_location(result, "utf-8", true)
end

local function js_eco_system_formatter()
	local package_json = require("lspconfig").util.root_pattern("package.json")
	local path = package_json(vim.fn.getcwd())

	if path == nil then
		return nil
	end

	local util = require("formatter.util")
	local bin_path = path .. "/node_modules/.bin/eslint"

	return {
		exe = bin_path,
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

return {
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
				command = ":FormatWrite",
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

					js = {
						js_eco_system_formatter,
					},

					ts = {
						js_eco_system_formatter,
					},

					vue = {
						js_eco_system_formatter,
					},

					rust = {
						require("formatter.filetypes.rust").rustfmt,
					},

					["*"] = {
						require("formatter.filetypes.any").remove_trailing_whitespace,
					},
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
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
		},
		init = function()
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
				-- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)

				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, opts)
				vim.keymap.set("n", "gi", function()
					vim.lsp.buf.implementation()
				end, opts)
				vim.keymap.set("n", "gD", function()
					vim.lsp.buf.declaration()
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
				vim.keymap.set("n", "<leader>vrr", function()
					vim.lsp.buf.references()
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
				"tsserver",
				"rust_analyzer",
				"lua_ls",
				"jsonls",
				"yamlls",
				"volar",
				"tailwindcss",
			}

			if utils.command_exists("composer") then
				table.insert(lsps_to_install, "phpactor")
			end

			require("mason-lspconfig").setup({
				ensure_installed = lsps_to_install,
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({})
					end,
				},
			})

			vim.lsp.handlers["textDocument/definition"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/references"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/implementation"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/declaration"] = open_lsp_location_in_new_tab
			vim.lsp.handlers["textDocument/typeDefinition"] = open_lsp_location_in_new_tab
		end,
	},
}
