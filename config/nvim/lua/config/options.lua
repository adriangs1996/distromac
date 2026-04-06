vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.cursorline = true

local undodir = os.getenv("HOME") .. "/.nvim/undodir"

if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

vim.opt.undodir = undodir
vim.opt.undofile = true

vim.opt.colorcolumn = "120"
vim.opt.scrolloff = 15

vim.opt.iskeyword:append("-")
vim.opt.iskeyword:append("/")
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.wrap = true
vim.opt.updatetime = 50
vim.opt.smartindent = true
