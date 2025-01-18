-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local k = vim.keymap

k.set("n", "\\<CR>", ":nohlsearch<CR>", { noremap = true, silent = true, desc = "Turn off highlight search results" })

k.set("n", "\\ta", ":tab all<CR>", { noremap = true, silent = true, desc = "Open multiple files into tabs at once" })
k.set(
  "n",
  "<F5>",
  [[:%s/\s\+$//e<cr>]],
  { noremap = true, silent = true, desc = "Remove all trailing whitespace by pressing F5" }
)

-- Unset ctrl-left/right
k.del("n", "<C-Left>")
k.del("n", "<C-Right>")

k.set({ "n", "v" }, "<C-S-Up>", ":m -2<CR>", { desc = "Move the current line up" })
k.set({ "v", "n" }, "<C-S-Down>", ":m +1<CR>", { desc = "Move the current line down" })
