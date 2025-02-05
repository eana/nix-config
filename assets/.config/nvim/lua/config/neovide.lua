local M = {}

function M.setup()
  if vim.g.neovide then
    -- Configure copy/paste shortcuts
    vim.keymap.set("n", "<A-s>", ":w<CR>") -- Save
    vim.keymap.set("v", "<A-c>", '"+y') -- Copy
    vim.keymap.set("n", "<A-v>", '"+P') -- Paste normal mode
    vim.keymap.set("v", "<A-v>", '"+P') -- Paste visual mode
    vim.keymap.set("c", "<A-v>", "<C-R>+") -- Paste command mode
    vim.keymap.set("i", "<A-v>", '<ESC>l"+Pli') -- Paste insert mode

    -- Allow clipboard copy paste in neovim
    vim.api.nvim_set_keymap("", "<A-v>", "+p<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("!", "<A-v>", "<C-R>+", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("t", "<A-v>", "<C-R>+", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("v", "<A-v>", "<C-R>+", { noremap = true, silent = true })

    -- Disable all animations
    vim.g.neovide_position_animation_length = 0
    vim.g.neovide_cursor_animation_length = 0.00
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = false
    vim.g.neovide_scroll_animation_far_lines = 0
    vim.g.neovide_scroll_animation_length = 0.00
  end
end

return M
