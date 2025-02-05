-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local options = vim.opt
local api = vim.api

local has = function(item)
  return vim.fn.has(item) == 1
end

-- Remove frustrations
api.nvim_set_keymap("n", "C", '"_C', { noremap = true, silent = true })
api.nvim_set_keymap("n", "D", '"_D', { noremap = true, silent = true })

api.nvim_set_keymap("n", "d", '"_d', { noremap = true, silent = true })
api.nvim_set_keymap("n", "dd", '"_dd', { noremap = true, silent = true })
api.nvim_set_keymap("n", "x", '"_x', { noremap = true, silent = true })
api.nvim_set_keymap("n", "c", '"_c', { noremap = true, silent = true })

-- Configure spellchecking
options.spelllang = "en_us"
options.spell = true
options.spelloptions = "camel"
api.nvim_set_hl(0, "SpellBad", { underline = true, fg = "#E06C75" })

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
else
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
end

-- Configure Neovim to have custom shortcuts for common actions during an
-- interactive Git rebase
require("config.git-rebase-config")

options.wildignore:append({
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

-- Load neovide configuration
require("config.neovide").setup()
