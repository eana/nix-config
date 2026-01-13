{
  programs.nixvim = {
    autoGroups = {
      auto_create_dir = { };
      checktime = { };
      fix_comment_indent = { };
      git_rebase_mappings = { };
      highlight_yank = { };
      highlight_trailing_whitespaces = { };
      json_conceal = { };
      last_loc = { };
      lsp_keymaps = { };
    };

    autoCmd = [
      # Auto create dir when saving a file
      {
        event = [ "BufWritePre" ];
        group = "auto_create_dir";
        callback.__raw = ''
          function(event)
            if event.match:match("^%w%w+:[\\/][\\/]") then
              return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
      }

      # Check if we need to reload the file when it changed
      {
        event = [
          "FocusGained"
          "TermClose"
          "TermLeave"
        ];
        group = "checktime";
        callback.__raw = ''
          function()
            if vim.o.buftype ~= "nofile" then
              vim.cmd("checktime")
            end
          end
        '';
      }

      # Stop '#' from jumping to column 1 in all filetypes
      {
        event = [ "FileType" ];
        group = "fix_comment_indent";
        pattern = [ "*" ];
        callback.__raw = ''
          function()
            -- Disable smartindent which is the primary cause
            vim.opt_local.smartindent = false
            -- Remove the '#' trigger from indentkeys and cinkeys
            vim.opt_local.indentkeys:remove("0#")
            vim.opt_local.cinkeys:remove("0#")
          end
        '';
      }

      # Git rebase: single-key command mappings (pick/squash/etc) + help footer
      {
        event = [ "FileType" ];
        group = "git_rebase_mappings";
        pattern = [ "gitrebase" ];
        callback.__raw = ''
          function(event)
            local buf = event.buf

            local function set_line_cmd(ln, cmd)
              local line = vim.api.nvim_buf_get_lines(buf, ln, ln + 1, false)[1]
              if not line or line:match("^#") or line:match("^%s*$") then return end
              local new_line = line:gsub("^(%S+)", cmd, 1)
              if new_line ~= line then
                vim.api.nvim_buf_set_lines(buf, ln, ln + 1, false, { new_line })
              end
            end

            local function set_range_cmd(start_ln, end_ln, cmd)
              local lines = vim.api.nvim_buf_get_lines(buf, start_ln, end_ln + 1, false)
              local new_lines = {}
              local modified = false

              for _, line in ipairs(lines) do
                if not line:match("^#") and not line:match("^%s*$") then
                  local new_l = line:gsub("^(%S+)", cmd, 1)
                  if new_l ~= line then
                    table.insert(new_lines, new_l)
                    modified = true
                  else
                    table.insert(new_lines, line)
                  end
                else
                  table.insert(new_lines, line)
                end
              end

              if modified then
                vim.api.nvim_buf_set_lines(buf, start_ln, end_ln + 1, false, new_lines)
              end
            end

            local actions = {
              p = "pick", r = "reword", e = "edit", s = "squash",
              f = "fixup", b = "break", d = "drop", t = "reset",
            }

            for key, action in pairs(actions) do
              vim.keymap.set("n", key, function()
                local ln = vim.api.nvim_win_get_cursor(0)[1] - 1
                set_line_cmd(ln, action)
              end, { buffer = buf, nowait = true, silent = true, desc = action })

              vim.keymap.set("v", key, function()
                local v_pos = vim.fn.getpos("v")
                local c_pos = vim.fn.getpos(".")
                local s_ln = math.min(v_pos[2], c_pos[2]) - 1
                local e_ln = math.max(v_pos[2], c_pos[2]) - 1
                set_range_cmd(s_ln, e_ln, action)
                vim.api.nvim_input("<Esc>")
              end, { buffer = buf, nowait = true, silent = true, desc = action .. " (selection)" })
            end

            local line_count = vim.api.nvim_buf_line_count(buf)
            local footer = vim.api.nvim_buf_get_lines(buf, math.max(0, line_count - 10), -1, false)
            local has_help = false
            for _, l in ipairs(footer) do
              if l:match("^# Shortcuts:") then has_help = true break end
            end

            if not has_help then
              local help = {
                "", "#", "# Shortcuts:",
                "#   p,r,e,s,f,b,d,t -> (n)ormal / (v)isual", "#"
              }
              vim.api.nvim_buf_set_lines(buf, -1, -1, false, help)
            end
          end
        '';
      }

      # Highlight on yank
      {
        event = [ "TextYankPost" ];
        desc = "Highlight when yanking (copying) text";
        group = "highlight_yank";
        callback.__raw = ''
          function()
            vim.highlight.on_yank()
          end
        '';
      }

      # Highlight trailing whitespace
      {
        event = [ "VimEnter" ];
        group = "highlight_trailing_whitespaces";
        callback.__raw = ''
          function()
            vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "red" })
            vim.fn.matchadd("TrailingWhitespace", "\\s\\+$")
          end
        '';
      }

      # Fix conceallevel for json files
      {
        event = [ "FileType" ];
        group = "json_conceal";
        pattern = [
          "json"
          "jsonc"
          "json5"
        ];
        callback.__raw = ''
          function()
            vim.opt_local.conceallevel = 0
          end
        '';
      }

      # Go to last loc when opening a buffer
      {
        event = [ "BufReadPost" ];
        group = "last_loc";
        callback.__raw = ''
          function(event)
            local exclude = { "gitcommit" }
            local buf = event.buf
            if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
              return
            end
            vim.b[buf].lazyvim_last_loc = true
            local mark = vim.api.nvim_buf_get_mark(buf, '"')
            local lcount = vim.api.nvim_buf_line_count(buf)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
      }

      # Buffer-local LSP keymaps when a language server attaches
      {
        event = [ "LspAttach" ];
        group = "lsp_keymaps";
        desc = "Setup buffer-local LSP keymaps when a language server attaches";
        callback.__raw = ''
          function(event)
            local buf = event.buf
            local opts = { buffer = buf, silent = true }

            -- Navigation
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
            vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))

            -- Documentation
            vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

            -- Refactor / actions
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code actions" }))
          end
        '';
      }
    ];
  };
}
