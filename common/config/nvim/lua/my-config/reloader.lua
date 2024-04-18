local M = {}

--- Reload the entire configuration
function M.my_config_reload_config()
    for name, _ in pairs(package.loaded) do
        if string.match(name, "^my%-config") then
            package.loaded[name] = nil
        end
    end

    require('my-config')

    -- Reload after/ directory
    local glob = vim.fn.stdpath('config') .. '/after/**/*.lua'
    local after_lua_filepaths = vim.fn.glob(glob, true, true)

    for _, filepath in ipairs(after_lua_filepaths) do
        dofile(filepath)
    end

    vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

return M
