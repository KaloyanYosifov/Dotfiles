-- Only GPG, symmetric encryption.
-- Encrypted files are detected by content, not extension, so any file name works.
local utils = require("my-config.utils")

local M = {}

-- Kept out of M so other code can't read the passphrases through require("my-config.crypt")
local encrypted_buffers = {}

local group = vim.api.nvim_create_augroup("MyConfigCrypt", { clear = true })

local ARMOR_HEADER = "-----BEGIN PGP MESSAGE-----"

local function is_encrypted_file(path)
	local f = io.open(path, "rb")
	if f == nil then
		return false
	end

	local head = f:read(#ARMOR_HEADER) or ""
	f:close()

	if head == ARMOR_HEADER then
		return true
	end

	-- Binary OpenPGP packet header for an encrypted session key (tag 1 public key, tag 3 symmetric),
	-- in old or new packet format. None of these bytes can start a UTF-8 text file.
	local b = head:byte(1)
	if b == nil then
		return false
	end

	return (b >= 0x84 and b <= 0x87) or (b >= 0x8C and b <= 0x8F) or b == 0xC1 or b == 0xC3
end

-- The passphrase is the first line on stdin, anything after it is the data to encrypt.
-- Keeps the passphrase off the command line, where `ps` would show it.
local function gpg(args, pass, data)
	local cmd = { "gpg", "--batch", "--yes", "--quiet", "--pinentry-mode", "loopback", "--passphrase-fd", "0" }
	vim.list_extend(cmd, args)

	return vim.system(cmd, { stdin = pass .. "\n" .. (data or "") }):wait()
end

local function remove_undo_file(path)
	if path == "" then
		return
	end

	local undo_path = vim.fn.undofile(path)

	if undo_path ~= "" then
		os.remove(undo_path)
	end
end

local function on_write(args)
	local buf = args.buf
	local state = encrypted_buffers[buf]
	local path = vim.fn.fnamemodify(args.file, ":p")
	local temp_path = path .. ".enc"

	local eol = vim.bo[buf].fileformat == "dos" and "\r\n" or "\n"
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local result = gpg({ "--symmetric", "-o", temp_path }, state.pass, table.concat(lines, eol) .. eol)

	if result.code ~= 0 then
		os.remove(temp_path)
		vim.notify("Crypt: encryption failed, file not written\n" .. (result.stderr or ""), vim.log.levels.ERROR)

		return
	end

	local stat = vim.uv.fs_stat(path)
	if stat then
		vim.uv.fs_chmod(temp_path, bit.band(stat.mode, tonumber("777", 8)))
	end

	local ok, err = os.rename(temp_path, path)
	if not ok then
		os.remove(temp_path)
		vim.notify("Crypt: could not replace " .. path .. ": " .. err, vim.log.levels.ERROR)

		return
	end

	if path == vim.api.nvim_buf_get_name(buf) then
		vim.bo[buf].modified = false
	end
end

local function refuse_partial_write()
	vim.notify("Crypt: range and append writes are disabled for encrypted buffers", vim.log.levels.ERROR)
end

local function attach(buf, pass)
	encrypted_buffers[buf] = {
		pass = pass,
	}

	-- shada would persist registers, search and command history taken from the plaintext.
	-- It stays off for the rest of the session, since the registers still hold that text.
	vim.o.shada = ""

	vim.bo[buf].undofile = false
	remove_undo_file(vim.api.nvim_buf_get_name(buf))

	vim.api.nvim_clear_autocmds({ group = group, buffer = buf })

	-- BufWriteCmd replaces the normal write, so plaintext never reaches the disk
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = group,
		buffer = buf,
		callback = on_write,
	})

	-- :1,5w file and :w >> file skip BufWriteCmd and would write plaintext
	vim.api.nvim_create_autocmd({ "FileWriteCmd", "FileAppendCmd" }, {
		group = group,
		buffer = buf,
		callback = refuse_partial_write,
	})

	vim.api.nvim_create_autocmd("BufWipeout", {
		group = group,
		buffer = buf,
		callback = function()
			encrypted_buffers[buf] = nil
		end,
	})
end

local function on_read(args)
	local buf = args.buf
	local path = vim.api.nvim_buf_get_name(buf)

	if path == "" or not is_encrypted_file(path) then
		return
	end

	vim.bo[buf].undofile = false
	remove_undo_file(path)

	local state = encrypted_buffers[buf]
	local pass = state and state.pass or nil
	local result

	while true do
		if pass == nil then
			pass = vim.fn.inputsecret("Password for " .. vim.fn.fnamemodify(path, ":t") .. " (empty to cancel): ")
		end

		if pass == "" then
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end)

			return
		end

		result = gpg({ "--decrypt", path }, pass)

		if result.code == 0 then
			break
		end

		vim.notify("Crypt: wrong password", vim.log.levels.WARN)
		pass = nil
	end

	local stdout = result.stdout or ""
	vim.bo[buf].fileformat = stdout:find("\r\n", 1, true) and "dos" or "unix"

	local lines = vim.split(stdout, "\r?\n")
	if lines[#lines] == "" then
		table.remove(lines)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	utils.clear_undo_history(buf)
	vim.bo[buf].modified = false

	attach(buf, pass)
end

local function mark_buffer_for_encryption(buf)
	local pass = nil

	while pass == nil do
		pass = utils.ask_password("Enter password (or type exit): ")

		if pass == "exit" then
			return
		end

		local confirm = utils.ask_password("Confirm password: ")

		if confirm ~= pass then
			pass = nil
		end
	end

	attach(buf, pass)

	vim.notify("Crypt: buffer will be encrypted on write")
end

local function setup_commands()
	vim.api.nvim_create_user_command("CryptEncryptFile", function()
		mark_buffer_for_encryption(vim.api.nvim_get_current_buf())
	end, {})
end

M.setup = function()
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = group,
		pattern = "*",
		callback = on_read,
	})

	setup_commands()
end

return M
