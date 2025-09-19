-- vim.opt are automatically loaded before lazy.nvim startup
-- Default vim.opt that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/vim.opt.lua
-- Add any additional vim.opt here

local has = function(item)
  return vim.fn.has(item) == 1
end

vim.opt.colorcolumn = "80,120"
vim.opt.list = true
vim.opt.conceallevel = 0

-- vim.opt.updatetime = 100
-- vim.opt.scrolloff = 9999

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.background = "dark"
vim.opt.termguicolors = true

vim.opt.completeopt = "menuone,noselect"

-- Highlight trailing whitespace
vim.cmd("highlight TrailingWhitespace ctermbg=red guibg=red")
vim.cmd("match TrailingWhitespace /\\s\\+$/")

-- Remove frustrations
vim.api.nvim_set_keymap("n", "C", '"_C', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "D", '"_D', { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "d", '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dd", '"_dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "x", '"_x', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "c", '"_c', { noremap = true, silent = true })

-- Configure spellchecking
vim.opt.spelllang = "en_us"
vim.opt.spell = true
vim.opt.spelloptions = "camel"
vim.api.nvim_set_hl(0, "SpellBad", { underline = true, fg = "#E06C75" })

-- Configure clipboard integration based on OS/environment
if has("wsl") then
  vim.g.clipboard = {
    name = "wsl-clipboard",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = true,
  }
elseif has("mac") or has("macunix") then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = true,
  }
elseif os.getenv("XDG_SESSION_TYPE") == "wayland" then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy --foreground --type text/plain",
      ["*"] = "wl-copy --foreground --primary --type text/plain",
    },
    paste = {
      ["+"] = function()
        return vim.fn.systemlist('wl-paste --no-newline|sed -e "s/\r$//"', { "" }, 1) -- '1' keeps empty lines
      end,
      ["*"] = function()
        return vim.fn.systemlist('wl-paste --primary --no-newline|sed -e "s/\r$//"', { "" }, 1)
      end,
    },
    cache_enabled = true,
  }
elseif os.getenv("DISPLAY") then
  vim.g.clipboard = {
    name = "xsel_override",
    copy = {
      ["+"] = "xsel --input --clipboard",
      ["*"] = "xsel --input --primary",
    },
    paste = {
      ["+"] = "xsel --output --clipboard",
      ["*"] = "xsel --output --primary",
    },
    cache_enabled = true,
  }
else
  -- No clipboard support
  vim.g.clipboard = nil
end

-- Ignore some default vim color schemes to reduce noise when using :colorscheme <Tab>
vim.opt.wildignore:append({
  "blue.vim",
  "darkblue.vim",
  "delek.vim",
  "desert.vim",
  "elflord.vim",
  "evening.vim",
  "habamax.vim",
  "industry.vim",
  "koehler.vim",
  "lunaperche.vim",
  "morning.vim",
  "murphy.vim",
  "pablo.vim",
  "peachpuff.vim",
  "quiet.vim",
  "retrobox.vim",
  "ron.vim",
  "shine.vim",
  "slate.vim",
  "sorbet.vim",
  "torte.vim",
  "wildcharm.vim",
  "zaibatsu.vim",
  "zellner.vim",
})
