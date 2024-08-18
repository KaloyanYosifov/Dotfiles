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
	if file == nil or file == " " then
		return false
	end

	local f = io.open(file)
	local exists = false

	if f ~= nil then
		exists = true
		io.close(f)
	end

	return exists
end

function M.get_current_file_uri()
	local bufnr = vim.api.nvim_get_current_buf()

	return vim.uri_from_bufnr(bufnr)
end

function M.is_buffer_uri_already_open(uri)
	local windows = vim.api.nvim_list_wins()

	for _, win in ipairs(windows) do
		local bufnr = vim.api.nvim_win_get_buf(win)

		if vim.api.nvim_buf_is_loaded(bufnr) then
			if uri == vim.uri_from_bufnr(bufnr) then
				return true
			end
		end
	end

	return false
end

function M.get_sql_at_current_cursor()
	local ts_utils = require("nvim-treesitter.ts_utils")
	local current_node = ts_utils.get_node_at_cursor()

	local last_statement = nil
	while current_node do
		if current_node:type() == "statement" then
			last_statement = current_node
		end

		if current_node:type() == "program" then
			break
		end

		current_node = current_node:parent()
	end

	if not last_statement then
		return ""
	end

	local srow, scol, erow, ecol = vim.treesitter.get_node_range(last_statement)
	local selection = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})
	return table.concat(selection, "\n")
end

function M.get_env(name, default)
	return os.getenv(name) or default
end

function M.notify(text, ttl)
	require("fidget").notify(text, nil, { ttl })
end

return M
