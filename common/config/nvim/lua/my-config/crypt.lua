-- Only GPG
local utils = require("my-config.utils")

local M = {
    encrypted_buffers = {}
}

local function get_current_buf_state_pass()
    local current_buf = vim.api.nvim_get_current_buf()
    local buffer_crypt_state = M.encrypted_buffers[current_buf]

    if buffer_crypt_state == nil then
        return nil
    end

    return buffer_crypt_state.pass
end

local function on_read()
    local current_buf = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(current_buf)
    local is_file_encrypted = utils.execute_for_status(string.format("file %s | grep PGP", filename))

    if is_file_encrypted ~= 0 then
        return
    end

    local decrypted_text
    local pass = get_current_buf_state_pass()

    while true do
        if pass == nil or pass == "" then
            pass = utils.ask_password()
        end

        decrypted_text = utils.execute(
            string.format(
                "gpg -d --pinentry-mode loopback --passphrase \"%s\" %s 2>/dev/null || echo \"__INVALID_PASS__\"",
                pass,
                filename
            )
        )

        if decrypted_text == "__INVALID_PASS__" then
            pass = nil
            local response = vim.fn.input("Password is invalid. Do you want to exit? (Type exit or enter to continue)");

            if response == "exit" then
                vim.cmd("q!")
                break
            end
        end

        break
    end

    decrypted_text = utils.split_string(decrypted_text, "\n")

    vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, decrypted_text)

    M.encrypted_buffers[current_buf] = {
        pass = pass
    }
end

local function on_write()
    local pass = get_current_buf_state_pass()
    local current_buf = vim.api.nvim_get_current_buf()

    if pass == nil then
        return
    end

    local filename = vim.api.nvim_buf_get_name(current_buf)
    local temp_filename = filename .. ".enc"

    utils.execute(
        string.format("gpg --symmetric --pinentry-mode loopback --passphrase \"%s\" -o %s %s 2>/dev/null",
            pass,
            temp_filename,
            filename
        )
    )

    vim.api.nvim_exec(string.format("!rm %s", filename), true)
    vim.api.nvim_exec(string.format("!mv %s %s", temp_filename, filename), true)
end

local function on_leave()
    local current_buf = vim.api.nvim_get_current_buf()

    M.encrypted_buffers[current_buf] = nil
end

M.setup = function()
    vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*",
        callback = on_read,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*",
        callback = on_write,
    })

    vim.api.nvim_create_autocmd("QuitPre", {
        pattern = "*",
        callback = on_leave,
    })
end

return M
