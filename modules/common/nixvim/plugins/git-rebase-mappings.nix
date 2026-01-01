_:

{
  programs.nixvim = {
    extraConfigLua = ''
      local group = vim.api.nvim_create_augroup("GitRebaseMappings", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "gitrebase",
        callback = function(event)
          local buf = event.buf

          local function set_line_cmd(ln, cmd)
            local line = vim.api.nvim_buf_get_lines(buf, ln, ln + 1, false)[1]
            if not line or line:match("^#") or line:match("^%s*$") then return end
            
            -- "pick commit..." -> "squash commit..."
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
            -- Normal Mode: Direct mapping for maximum speed
            vim.keymap.set("n", key, function()
              local ln = vim.api.nvim_win_get_cursor(0)[1] - 1
              set_line_cmd(ln, action)
            end, { buffer = buf, nowait = true, silent = true, desc = action })

            -- Visual Mode: Calculate range dynamically + Batch update
            vim.keymap.set("v", key, function()
              -- 
              -- Use getpos("v") and getpos(".") to get the real-time selection
              -- This is safer than '< and '> inside a mapping
              local v_pos = vim.fn.getpos("v")
              local c_pos = vim.fn.getpos(".")
              local s_ln = math.min(v_pos[2], c_pos[2]) - 1
              local e_ln = math.max(v_pos[2], c_pos[2]) - 1
              
              set_range_cmd(s_ln, e_ln, action)
              
              -- Optional: Exit visual mode smoothly (comment out if you prefer staying in visual)
              vim.api.nvim_input("<Esc>")
            end, { buffer = buf, nowait = true, silent = true, desc = action .. " (selection)" })
          end

          -- Only scan the end of the file to prevent lag on large rebase lists
          local line_count = vim.api.nvim_buf_line_count(buf)
          -- Check last 10 lines
          local footer = vim.api.nvim_buf_get_lines(buf, math.max(0, line_count - 10), -1, false)
          local has_help = false
          for _, l in ipairs(footer) do
            if l:match("^# Shortcuts:") then has_help = true break end
          end

          if not has_help then
             -- (Your help text logic here...)
             local help = {
               "", "#", "# Shortcuts:", 
               "#   p,r,e,s,f,b,d,t -> (n)ormal / (v)isual", "#" 
             }
             vim.api.nvim_buf_set_lines(buf, -1, -1, false, help)
          end
        end,
      })
    '';
  };
}
