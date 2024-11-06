-- vim.transparent_window = true
vim.opt.guicursor = ""
vim.opt.background = "dark"
vim.opt.bg = "dark"
vim.opt.termguicolors = true

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', 'C-c', '<cmd>nohlsearch<CR>')


vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.showmode = false
vim.opt.ruler = false

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

-- vim.opt.colorcolumn = "80"

vim.g.mapleader = " "

-- let g:omni_sql_no_default_maps = 1
-- it was annoying in sql files
vim.g.omni_sql_no_default_maps = 1