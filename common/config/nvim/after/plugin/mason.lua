local utils = require("my-config.utils")

local lsps_to_install = {
    "tsserver",
    "rust_analyzer",
    "lua_ls",
    "jsonls",
    "yamlls",
    "volar",
    "tailwindcss"
}
local dap_adapters_to_install = {
    "codelldb",
    "cpptools"
}

if (utils.command_exists("composer")) then
    table.insert(lsps_to_install, "phpactor");
end

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = lsps_to_install,
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end
    }
})
require('mason-nvim-dap').setup({
    ensure_installed = dap_adapters_to_install,
})
