local utils = require("my-config.utils")
local debug_mode = utils.get_env("NVIM_LSP_DEBUG", "0") == "1"

local vue_language_server_path = vim.fn.expand("$MASON/packages/vue-language-server")
	.. "/node_modules/@vue/language-server"

local config = {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
	},

	settings = {
		complete_function_calls = true,
		vtsls = {
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
			experimental = {
				maxInlayHintLength = 30,
				completion = {
					enableServerSideFuzzyMatch = true,
				},
			},
			tsserver = {
				globalPlugins = {
					{
						name = "@vue/typescript-plugin",
						location = vue_language_server_path,
						languages = { "typescript", "javascript", "vue" },
						configNamespace = "typescript",
						enableForWorkspaceTypeScriptVersions = true,
					},
				},
			},
		},
		typescript = {
			preferences = {
				includeInlayParameterNameHints = "literals",
				includeInlayVariableTypeHints = true,
				includeInlayEnumMemberValueHints = true,
				preferTypeOnlyAutoImports = true,
				importModuleSpecifierPreference = "non-relative",
			},
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = true },
			},
		},
		javascript = {
			preferences = {
				importModuleSpecifier = "non-relative",
			},
			implicitProjectConfig = {
				checkJs = true,
				strictNullChecks = true,
				strictFunctionTypes = true,
				strict = true,
			},
			inlayHints = {
				parameterNames = { enabled = "all" },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
			},
		},
	},

	on_attach = function(client, bufnr)
		if vim.bo[bufnr].filetype == "vue" then
			client.server_capabilities.semanticTokensProvider.full = false
		else
			client.server_capabilities.semanticTokensProvider.full = true
		end
	end,
}

if debug_mode then
	config.settings.vtsls.tsserver.logVerbosity = "verbose"
end

return config
