return {
	on_attach = function(client, _)
		client.server_capabilities.completionProvider = nil
		client.server_capabilities.definitionProvider = nil
		client.server_capabilities.referencesProvider = nil
		client.server_capabilities.hoverProvider = nil
	end,
	init_options = {
		["completion.import_globals"] = true,
		["indexer.exclude_patterns"] = { "**/node_modules/**", "**/.git/**" },

		-- no-diagnostics
		["language_server.diagnostics_on_update"] = false, -- no diagnostics on text change
		["language_server.diagnostics_on_open"] = false, -- no diagnostics when opening file
		["language_server.diagnostics_on_save"] = false, -- no diagnostics on save

		["language_server_phpstan.enabled"] = false,
		["language_server_psalm.enabled"] = false,
	},
}
