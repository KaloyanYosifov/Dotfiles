local utils = require("my-config.utils")
local dap = require("dap")

if vim.fn.has("macunix") then
    local function init()
        if not utils.command_exists("lldb-vscode") and not utils.command_exists("lldb-dap") then
            print("lldb-vscode or lldb-dap not found!")
            print(
                "Please install llvm: brew install llvm and then link vscode or dap. `ln -s /opt/homebrew/opt/llvm/bin/lldb-vscode /opt/homebrew/bin/lldb-vscode`"
            )

            return
        end

        dap.adapters.lldb = {
            type = "executable",
            command = utils.command_path("lldb-vscode"),
            name = "lldb"
        }

        dap.configurations.rust = {
            {
                name = 'Launch',
                type = 'lldb',
                request = 'launch',
                program = function()
                    return '' -- executable
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = {},
                initCommands = function()
                    -- Find out where to look for the pretty printer Python module
                    local rustc_sysroot = utils.execute('rustc --print sysroot')

                    local script_import = 'command script import "' ..
                        rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                    local commands_file = rustc_sysroot .. '/lib/rustlib/etc/lldb_commands'

                    local commands = {}
                    local file = io.open(commands_file, 'r')
                    if file then
                        for line in file:lines() do
                            table.insert(commands, line)
                        end
                        file:close()
                    end
                    table.insert(commands, 1, script_import)

                    return commands
                end,
                -- ...,
            }
        }
    end

    init()
else
    dap.adapters.gdb = {

    }
end

-- map K to hover
local api = vim.api
local keymap_restore = {}
dap.listeners.after['event_initialized']['me'] = function()
    for _, buf in pairs(api.nvim_list_bufs()) do
        local keymaps = api.nvim_buf_get_keymap(buf, 'n')
        for _, keymap in pairs(keymaps) do
            if keymap.lhs == "K" then
                table.insert(keymap_restore, keymap)
                api.nvim_buf_del_keymap(buf, 'n', 'K')
            end
        end
    end
    api.nvim_set_keymap(
        'n', 'K', '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
end

dap.listeners.after['event_terminated']['me'] = function()
    for _, keymap in pairs(keymap_restore) do
        api.nvim_buf_set_keymap(
            keymap.buffer,
            keymap.mode,
            keymap.lhs,
            keymap.rhs,
            { silent = keymap.silent == 1 }
        )
    end
    keymap_restore = {}
end

-- Mappings
vim.keymap.set("n", "<leader>rc", ":lua require('dap').continue()<cr>")
vim.keymap.set("n", "<leader>rb", ":lua require('dap').toggle_breakpoint()<cr>")
