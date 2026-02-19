local utils = require("my-config.utils")
local telescope_builtin = require("telescope.builtin")
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
	-- Currently too slow with go to definition
	-- wait for that fix
	--"laravel_ls",
}

if utils.command_exists("composer") then
	table.insert(lsps_to_install, "intelephense")
	table.insert(lsps_to_install, "phpactor")
end

local function open_lsp_location_in_new_tab(_, result, ctx, _)
	if not result or vim.tbl_isempty(result) then
		print("No location found for " .. ctx.method)
		return
	end

	-- Normalize to single location (most common case)
	if vim.islist(result) then
		result = result[1]
	end

	local uri = result.uri or result.targetUri
	if not uri then
		return
	end

	local filename = vim.uri_to_fname(uri)

	-- Check if buffer is loaded and visible in any window
	local bufnr = vim.fn.bufnr(filename)
	local win_id = bufnr > 0 and vim.fn.bufwinid(bufnr) or -1

	if win_id > 0 then
		-- Buffer is open somewhere → switch to its tab and window
		vim.fn.win_gotoid(win_id)
		-- Optional: ensure focus (usually not needed after win_gotoid)
		vim.api.nvim_set_current_buf(bufnr)
	else
		-- Not open anywhere → force new tab
		vim.cmd("tabnew")
		vim.lsp.util.show_document(result, "utf-8", { focus = true })
	end

	-- If multiple locations, populate quickfix (optional, but nice)
	if vim.islist(result) and #result > 1 then
		vim.fn.setqflist(vim.lsp.util.locations_to_items(result, "utf-8"))
		vim.cmd("copen")
	end
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
				php = { "pint", "php-cs-fixer", stop_after_first = true },
				yaml = { "yamlfmt", "yamlfix", stop_after_first = true },
				-- go-jsonnet
				json = { "jsonnetfmt" },
				json5 = { "jsonnetfmt" },
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
					prepend_args = { "-formatter", "retain_line_breaks_single=true" },
				},
			},
		},
	},
	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "hrsh7th/cmp-cmdline" },
			{ "pontusk/cmp-sass-variables" },

			{ "windwp/nvim-autopairs" },
			{ "lukas-reineke/cmp-under-comparator" },
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				enabled = function()
					local context = require("cmp.config.context")
					local disabled = false
					disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
					disabled = disabled or (vim.fn.reg_recording() ~= "")
					disabled = disabled or (vim.fn.reg_executing() ~= "")
					disabled = disabled or context.in_treesitter_capture("comment")
					disabled = disabled or context.in_syntax_group("Comment")
					if vim.api.nvim_get_mode().mode == "c" then
						return true
					else
						return not disabled
					end
				end,
				sources = {
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
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
				sorting = {
					priority_weight = 3,
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						require("cmp-under-comparator").under,
						cmp.config.compare.kind,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
						cmp.config.compare.recently_used,
					},
				},
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},
			})

			cmp.setup.filetype({ "lua" }, {
				enabled = true,
				sources = {
					{ name = "nvim_lua" },
					{ name = "lazydev", group_index = 0 },
				},
			})

			cmp.setup.filetype({ "css", "scss" }, {
				enabled = true,
				sources = {
					{ name = "sass-variables" },
				},
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline({
					["<C-j>"] = { c = cmp.mapping.select_next_item() },
					["<C-k>"] = { c = cmp.mapping.select_prev_item() },
				}),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline({
					["<C-j>"] = { c = cmp.mapping.select_next_item() },
					["<C-k>"] = { c = cmp.mapping.select_prev_item() },
				}),
				sources = cmp.config.sources({
					{ name = "cmdline" },
				}),
			})

			cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

			-- FOR SCSS variables
			vim.g.sass_variables_file = "_variables.scss"

			-- -- map in command mode to autocomplete
			-- vim.keymap.set("c", "<C-k>", function()
			-- 	cmp.mapping.select_prev_item(cmp_select)
			-- end, { expr = true, noremap = true })
			--
			-- vim.keymap.set("c", "<C-j>", function()
			-- 	cmp.mapping.select_next_item(cmp_select)
			-- end, { expr = true, noremap = true })
		end,
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
			{ "hrsh7th/cmp-nvim-lsp" },
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
				severiy_sort = true,
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
						telescope_builtin.lsp_definitions({
							jump_type = "tab drop",
							reuse_win = true,
						})
					end, opts)
					vim.keymap.set("n", "gi", function()
						telescope_builtin.lsp_implementations({
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
						telescope_builtin.lsp_references({
							jump_type = "tab drop",
							reuse_win = true,
						})
					end, opts)
					vim.keymap.set("n", "<leader>k", function()
						vim.lsp.buf.hover()
					end, opts)
					vim.keymap.set("n", "[d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, opts)
					vim.keymap.set("n", "]d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, opts)
					vim.keymap.set("n", "<leader>cac", function()
						vim.lsp.buf.code_action()
					end, opts)
					vim.keymap.set("n", "<leader>vre", function()
						vim.lsp.buf.rename()
					end, opts)
					vim.keymap.set("n", "<leader>vrf", function()
						require("snacks").rename.rename_file()
					end, opts)
					vim.keymap.set("i", "<C-h>", function()
						vim.lsp.buf.signature_help()
					end, opts)
				end,
			})

			local capabilities = vim.tbl_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			for _, server_name in ipairs(lsps_to_install) do
				vim.lsp.config(server_name, { capabilities = capabilities })
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
