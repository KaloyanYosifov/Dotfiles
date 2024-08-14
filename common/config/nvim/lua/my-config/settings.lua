vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.encoding = "UTF-8"
vim.opt.backspace = "indent,eol,start"

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 12
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 300

vim.opt.colorcolumn = "120"

vim.opt.hidden = true
vim.opt.autowriteall = true

vim.opt.shortmess:append({ c = true })

vim.opt.cmdheight = 2

vim.opt.backup = false
vim.opt.writebackup = false

-- remove compat for vi and remove swap files
vim.opt.compatible = false
vim.opt.swapfile = false

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
