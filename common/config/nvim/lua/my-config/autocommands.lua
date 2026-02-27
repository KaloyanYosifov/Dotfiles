vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
	end,
})

-- file type override group
local fileTypeOverrideGroup = vim.api.nvim_create_augroup("FiletypeOverrides", { clear = true })

-- set markdown file type for mdc files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = fileTypeOverrideGroup,
	pattern = "*.mdc",
	callback = function()
		vim.bo.filetype = "markdown"
	end,
})
