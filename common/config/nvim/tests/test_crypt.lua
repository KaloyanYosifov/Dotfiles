local helpers = dofile("tests/helpers.lua")
local eq = helpers.eq

local PASS = 'p@ss "$w0rd'

local child = MiniTest.new_child_neovim()
local dir

local function gpg(args, stdin)
	local cmd = { "gpg", "--batch", "--yes", "--quiet", "--pinentry-mode", "loopback", "--passphrase-fd", "0" }
	vim.list_extend(cmd, args)

	return vim.system(cmd, { stdin = stdin }):wait()
end

local function encrypt(name, pass, content, extra_args)
	local path = dir .. "/" .. name
	local args = vim.list_extend({ "--symmetric", "-o", path }, extra_args or {})
	local result = gpg(args, pass .. "\n" .. content)
	assert(result.code == 0, result.stderr)

	return path
end

local function decrypt(path, pass)
	return gpg({ "--decrypt", path }, pass).stdout
end

-- Queue answers for the password prompts; every prompt is counted in _G.asked
local function answer(...)
	child.lua("_G.answers = { ... }", { ... })
end

local function asked()
	return child.lua_get("_G.asked")
end

local function buf_lines()
	return child.api.nvim_buf_get_lines(0, 0, -1, false)
end

if vim.fn.executable("gpg") == 0 then
	local T = MiniTest.new_set()
	T["crypt"] = function()
		MiniTest.skip("gpg is not installed")
	end

	return T
end

local T = helpers.new_set(child, {
	-- Every case gets its own directory and gpg home, so no gpg-agent state leaks between cases
	pre_restart = function()
		dir = helpers.tempdir()
		vim.fn.mkdir(dir .. "/undo", "p")
		vim.fn.mkdir(dir .. "/gnupg", "p", tonumber("700", 8))
		vim.env.GNUPGHOME = dir .. "/gnupg"
	end,
	pre_case = function()
		child.fn.chdir(dir)
		child.lua(
			[[
				local dir = ...
				vim.o.undofile = true
				vim.o.undodir = dir .. "/undo"
				vim.o.shada = "'100,<50,s10,h"
				_G.answers, _G.asked = {}, 0
				vim.fn.inputsecret = function()
					_G.asked = _G.asked + 1
					return table.remove(_G.answers, 1) or ""
				end
				require("my-config.crypt").setup()
			]],
			{ dir }
		)
	end,
	post_case = function()
		vim.system({ "gpgconf", "--kill", "gpg-agent" }):wait()
	end,
})

T["detection"] = MiniTest.new_set()

T["detection"]["opens plain files without asking for a password"] = function()
	helpers.write_file(dir .. "/Plain.wiki", "just text\n")
	child.cmd("edit Plain.wiki")

	eq(asked(), 0)
	eq(buf_lines(), { "just text" })
end

T["detection"]["decrypts a binary gpg file whatever its extension"] = function()
	encrypt("File.wiki", PASS, "secret line\n  indented\n")
	answer(PASS)
	child.cmd("edit File.wiki")

	eq(buf_lines(), { "secret line", "  indented" })
	eq(child.bo.modified, false)
end

T["detection"]["decrypts an ascii armored file"] = function()
	encrypt("notes.txt", PASS, "armored\n", { "--armor" })
	answer(PASS)
	child.cmd("edit notes.txt")

	eq(buf_lines(), { "armored" })
end

T["password prompt"] = MiniTest.new_set()

T["password prompt"]["asks again after a wrong password"] = function()
	encrypt("File.wiki", PASS, "secret\n")
	answer("wrong", PASS)
	child.cmd("edit File.wiki")

	eq(asked(), 2)
	eq(buf_lines(), { "secret" })
end

T["password prompt"]["an empty password cancels and wipes the buffer"] = function()
	encrypt("File.wiki", PASS, "secret\n")
	answer("")
	child.cmd("edit File.wiki")

	local wiped = child.lua("return vim.wait(500, function() return vim.fn.bufnr('File.wiki') == -1 end)")
	eq(wiped, true)
end

T["password prompt"]["reuses the password after the buffer is unloaded"] = function()
	encrypt("File.wiki", PASS, "secret\n")
	answer(PASS)
	child.cmd("edit File.wiki")
	child.cmd("bdelete")
	child.cmd("edit File.wiki")

	eq(asked(), 1)
	eq(buf_lines(), { "secret" })
end

T["writing"] = MiniTest.new_set()

T["writing"]["re-encrypts on write and never leaves plaintext on disk"] = function()
	local path = encrypt("File.wiki", PASS, "secret\n")
	answer(PASS)
	child.cmd("edit File.wiki")
	child.api.nvim_buf_set_lines(0, -1, -1, false, { "added" })
	child.cmd("write")

	eq(child.bo.modified, false)
	eq(helpers.read_file(path):find("secret", 1, true), nil)
	eq(decrypt(path, PASS), "secret\nadded\n")
	eq(vim.uv.fs_stat(path .. ".enc"), nil)
end

T["writing"]["keeps the file permissions"] = function()
	local path = encrypt("File.wiki", PASS, "secret\n")
	vim.uv.fs_chmod(path, tonumber("600", 8))
	answer(PASS)
	child.cmd("edit File.wiki")
	child.cmd("write")

	eq(bit.band(vim.uv.fs_stat(path).mode, tonumber("777", 8)), tonumber("600", 8))
end

T["writing"]["keeps CRLF line endings"] = function()
	local path = encrypt("Crlf.txt", PASS, "a\r\nb\r\n")
	answer(PASS)
	child.cmd("edit Crlf.txt")

	eq(child.bo.fileformat, "dos")
	eq(buf_lines(), { "a", "b" })

	child.cmd("write")
	eq(decrypt(path, PASS), "a\r\nb\r\n")
end

T["writing"]["encrypts :w to another name too"] = function()
	encrypt("File.wiki", PASS, "secret\n")
	answer(PASS)
	child.cmd("edit File.wiki")
	child.cmd("write Copy.wiki")

	eq(helpers.read_file(dir .. "/Copy.wiki"):find("secret", 1, true), nil)
	eq(decrypt(dir .. "/Copy.wiki", PASS), "secret\n")
end

T["writing"]["refuses partial range and append writes"] = function()
	encrypt("File.wiki", PASS, "secret\nmore\n")
	answer(PASS)
	child.cmd("edit File.wiki")
	pcall(child.cmd, "1,1write partial.txt")
	pcall(child.cmd, "write >> append.txt")

	eq(vim.uv.fs_stat(dir .. "/partial.txt"), nil)
	eq(vim.uv.fs_stat(dir .. "/append.txt"), nil)
end

T["leaks"] = MiniTest.new_set()

T["leaks"]["disables undofile and removes an existing undo file"] = function()
	-- Edit the file as plaintext first so Neovim writes a real undo file for it
	helpers.write_file(dir .. "/File.wiki", "plain\n")
	child.cmd("edit File.wiki")
	child.api.nvim_buf_set_lines(0, 0, -1, false, { "old plaintext history" })
	child.cmd("write")
	child.cmd("bwipeout")
	local undo_file = child.fn.undofile(dir .. "/File.wiki")
	eq(vim.uv.fs_stat(undo_file) ~= nil, true)

	encrypt("File.wiki", PASS, "secret\n")
	answer(PASS)
	child.cmd("edit File.wiki")

	eq(child.bo.undofile, false)
	eq(vim.uv.fs_stat(undo_file), nil)
end

T["leaks"]["turns shada off once an encrypted file is open"] = function()
	encrypt("File.wiki", PASS, "secret\n")
	answer(PASS)
	child.cmd("edit File.wiki")

	eq(child.o.shada, "")
end

T["leaks"]["does not expose passphrases on the module"] = function()
	encrypt("File.wiki", PASS, "secret\n")
	answer(PASS)
	child.cmd("edit File.wiki")

	eq(child.lua_get("vim.tbl_keys(require('my-config.crypt'))"), { "setup" })
end

T[":CryptEncryptFile"] = MiniTest.new_set()

T[":CryptEncryptFile"]["encrypts a plain file on the next write"] = function()
	helpers.write_file(dir .. "/New.md", "fresh\n")
	child.cmd("edit New.md")
	answer("abc", "abc")
	child.cmd("CryptEncryptFile")
	child.cmd("write")

	eq(helpers.read_file(dir .. "/New.md"):find("fresh", 1, true), nil)
	eq(decrypt(dir .. "/New.md", "abc"), "fresh\n")
end

T[":CryptEncryptFile"]["asks again when the confirmation differs"] = function()
	helpers.write_file(dir .. "/New.md", "fresh\n")
	child.cmd("edit New.md")
	answer("abc", "abd", "xyz", "xyz")
	child.cmd("CryptEncryptFile")
	child.cmd("write")

	eq(asked(), 4)
	eq(decrypt(dir .. "/New.md", "xyz"), "fresh\n")
end

T[":CryptEncryptFile"]["exit leaves the file unencrypted"] = function()
	helpers.write_file(dir .. "/New.md", "fresh\n")
	child.cmd("edit New.md")
	answer("exit")
	child.cmd("CryptEncryptFile")
	child.cmd("write")

	eq(helpers.read_file(dir .. "/New.md"), "fresh\n")
end

return T
