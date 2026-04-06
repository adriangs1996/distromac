-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>fs", ":wa<CR>", { desc = "[S]ave file" })
vim.keymap.set("n", "<leader>fS", ":w<CR>", { desc = "[S]ave file" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "C-d", "<C-d>zz")
vim.keymap.set("n", "C-u", "<C-u>zz")
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste without overwriting register" })

local letters = "abcdefghijklmnopqrstuvwxyz"
for i = 1, #letters do
  local letter = letters:sub(i, i)
  vim.keymap.set("n", "." .. letter, "`" .. string.upper(letter), { desc = "Jump to mark [" .. letter .. "]" })
  vim.keymap.set(
    "n",
    "m" .. letter,
    "m" .. string.upper(letter),
    { desc = "Creates a mark as [" .. string.upper(letter) .. "]" }
  )
end

vim.keymap.set("n", "<c-k>", ":wincmd k <CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h <CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j <CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l <CR>")
vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>")
vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>")
vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>")

-- toggle statusline
local function toggle_statusline()
  local current_status = vim.o.laststatus
  if current_status == 0 then
    vim.o.laststatus = 2
    vim.notify("Statusline shown")
  else
    vim.o.laststatus = 0
    vim.notify("Statusline hidden")
  end
end
vim.o.laststatus = 0

vim.keymap.set("n", "<leader>ue", toggle_statusline, { desc = "Toggle statusline" })
vim.keymap.set("n", "j", function()
  if vim.v.count == 0 then
    return "gj"
  else
    return "j"
  end
end, { expr = true, desc = "Move down" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.keymap.set("n", "<leader>t", "<cmd>lua vim.cmd('RustLsp testables')<CR>", { desc = "Run Rust tests" })
    vim.keymap.set("n", "<leader>T", "<cmd>lua vim.cmd('RustTest')<CR>", { desc = "Run test under cursor" })
  end,
})
