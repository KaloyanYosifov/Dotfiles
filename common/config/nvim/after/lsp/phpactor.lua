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
	},
}
