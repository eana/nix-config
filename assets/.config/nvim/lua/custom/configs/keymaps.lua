vim.keymap.set("n", "<leader>l", "<cmd>Lazy<CR>")
vim.keymap.set(
  "n",
  "<F5>",
  [[:%s/\s\+$//e<cr>]],
  { noremap = true, silent = true, desc = "Remove all trailing whitespace by pressing F5" }
)
vim.keymap.set({ "n", "v" }, "<C-S-Up>", ":m -2<CR>", { desc = "Move the current line up" })
vim.keymap.set({ "v", "n" }, "<C-S-Down>", ":m +1<CR>", { desc = "Move the current line down" })

-- Buffer management
local Snacks = require("snacks")

vim.keymap.set("n", "<Space>`", "<Cmd>e #<CR>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", "<Cmd>:bd<CR>", { desc = "Delete Buffer and Window" })
vim.keymap.set("n", "<Space>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
vim.keymap.set("n", "<Space>bb", "<Cmd>e #<CR>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<Space>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<Space>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete Buffers to the Left" })
vim.keymap.set("n", "<Space>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
vim.keymap.set("n", "<Space>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete Buffers to the Right" })
