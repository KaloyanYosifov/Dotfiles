local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
    return
end

local Terminal  = require('toggleterm.terminal').Terminal

toggleterm.setup({
	size = 20,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "horizontal",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<S-j>', "<Cmd>lua require'toggleterm'.prev_terminal()<CR><Cmd>startinsert<CR>", opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<S-k>', "<Cmd>lua require'toggleterm'.next_terminal()<CR><Cmd>startinsert<CR>", opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-t>', "<Cmd>ToggleTerm<Cr><Cmd>lua require'toggleterm.terminal'.Terminal:new():toggle()<CR>i<BS>", opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

