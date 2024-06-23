local M = {}

function M.execute(command)
	return vim.fn.trim(vim.fn.system(command))
end

function M.execute_for_status(command)
	return os.execute(string.format("%s > /dev/null 2>&1", command))
end

function M.command_exists(command)
	-- TOOD: Should I sanitize my own input? It might be a good practice, just in case. !!
	return M.execute_for_status(string.format("command -v %s", command)) == 0
end

function M.command_path(command)
	return M.execute(string.format("command -v %s", command))
end

-- Credit: https://gist.github.com/jaredallard/ddb152179831dd23b230
function M.split_string(str, delimiter)
	local from = 1
	local result = {}
	local delim_from, delim_to = string.find(str, delimiter, from)

	while delim_from do
		table.insert(result, string.sub(str, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(str, delimiter, from)
	end

	table.insert(result, string.sub(str, from))

	return result
end

function M.ask_password(prompt)
	prompt = prompt and prompt or "Enter Password: "

	local pass = vim.fn.inputsecret(prompt)

	while pass == "" do
		vim.print("Password cannot be empty!")

		pass = vim.fn.inputsecret(prompt)
	end

	return pass
end

function M.clear_undo_history(buf)
	local undolevels = vim.api.nvim_buf_get_option(buf, "undolevels")

	vim.api.nvim_buf_set_option(buf, "undolevels", -1)

	vim.cmd('exe "normal a \\<BS>\\<Esc>"')

	vim.api.nvim_buf_set_option(buf, "undolevels", undolevels)
end

function M.file_exists(file)
	local f = io.open(file)
	local exists = false

	if f ~= nil then
		exists = true
	end

	io.close(f)

	return exists
end

return M
