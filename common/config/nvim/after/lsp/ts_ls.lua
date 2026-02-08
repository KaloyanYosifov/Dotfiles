local utils = require("my-config.utils")
local debug_mode = utils.get_env("NVIM_LSP_DEBUG", "0") == "1"
local config = {}

local vue_language_server_path = vim.fn.expand("$MASON/packages/vue-language-server")
	.. "/node_modules/@vue/language-server"

config = {
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = vue_language_server_path,
				languages = { "vue" },
				configNamespace = "typescript",
			},
		},
		preferences = {
			includeInlayParameterNameHints = "literals",
			includeInlayVariableTypeHints = true,
			includeInlayEnumMemberValueHints = true,
			preferTypeOnlyAutoImports = true,
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

return config
