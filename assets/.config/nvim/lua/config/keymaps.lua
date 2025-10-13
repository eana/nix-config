-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set(
  "n",
  "\\<CR>",
  ":nohlsearch<CR>",
  { noremap = true, silent = true, desc = "Turn off highlight search results" }
)

vim.keymap.set(
  "n",
  "<F5>",
  [[:%s/\s\+$//e<cr>]],
  { noremap = true, silent = true, desc = "Remove all trailing whitespace by pressing F5" }
)

-- Unset ctrl-left/right
vim.keymap.del("n", "<C-Left>")
vim.keymap.del("n", "<C-Right>")

vim.keymap.set({ "n", "v" }, "<C-S-Up>", ":m -2<CR>", { desc = "Move the current line up" })
vim.keymap.set({ "v", "n" }, "<C-S-Down>", ":m +1<CR>", { desc = "Move the current line down" })

-- Resize window
vim.keymap.set(
  "n",
  "<C-Up>",
  "<Cmd>resize -1<CR>",
  { noremap = true, silent = true, desc = "Increase Message Window Height" }
)
vim.keymap.set(
  "n",
  "<C-Down>",
  "<Cmd>resize +1<CR>",
  { noremap = true, silent = true, desc = "Decrease Message Window Height" }
)
