local M = {}

function M.execute(command)
    return vim.fn.trim(vim.fn.system(command))
end

function M.command_exists(command)
    -- TOOD: Should I sanitize my own input? It might be a good practice, just in case. !!
    return os.execute(string.format("command -v %s > /dev/null", command)) == 0
end

function M.command_path(command)
    return M.execute(string.format("command -v %s", command))
end

return M
