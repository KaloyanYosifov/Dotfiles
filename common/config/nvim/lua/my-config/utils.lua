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

function M.command_path(command, default)
	local commandExec = "command -v %s"

	if default ~= nil then
		commandExec = commandExec .. " || echo %s"
	end

	return M.execute(string.format(commandExec, command, default))
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
	local undolevels = vim.bo[buf].undolevels

	vim.bo[buf].undolevels = -1

	vim.api.nvim_buf_call(buf, function()
		vim.cmd('exe "normal a \\<BS>\\<Esc>"')
	end)

	vim.bo[buf].undolevels = undolevels
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
	local current_node = vim.treesitter.get_node()

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

function M.is_empty_table(t)
	if t == nil then
		return true
	end
	return next(t) == nil
end

function M.normalize(config, existing)
	local conf = existing
	if M.is_empty_table(config) then
		return conf
	end

	for k, v in pairs(config) do
		conf[k] = v
	end

	return conf
end

--- @param path string Absolute path to pick from
--- @param line? integer Optional line number to append
function M.copy_path_picker(path, line)
	local choices = { "Relative path", "Absolute path", "Filename only" }
	if line then
		table.insert(choices, "Relative path with line number")
	end
	vim.ui.select(choices, { prompt = "Copy path:" }, function(choice)
		if not choice then
			return
		end

		local result
		if choice == "Relative path" then
			result = vim.fn.fnamemodify(path, ":.")
		elseif choice == "Absolute path" then
			result = path
		elseif choice == "Filename only" then
			result = vim.fn.fnamemodify(path, ":t")
		elseif choice == "Relative path with line number" then
			result = vim.fn.fnamemodify(path, ":.") .. ":" .. line
		end

		vim.fn.setreg("+", result)
		vim.fn.setreg('"', result)
		vim.notify("Copied: " .. result)
	end)
end

--- @class utils.focus_window_on_filetype_opts
--- @field insert_mode? boolean
--- @param ft string
--- @param opts? utils.focus_window_on_filetype_opts
--- @return nil
function M.focus_window_on_filetype(ft, opts)
	opts = opts or {}

	-- schedule a command to give a breather for the buffer to open
	-- then focus on the window we want
	vim.schedule(function()
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			local buf = vim.api.nvim_win_get_buf(win)

			if vim.bo[buf].filetype == ft then
				vim.api.nvim_set_current_win(win)

				if opts.insert_mode then
					vim.cmd("startinsert!")
				end

				return
			end
		end
	end)
end

return M
