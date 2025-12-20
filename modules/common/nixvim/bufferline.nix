_:

{
  programs.nixvim.plugins.bufferline = {
    enable = true;
    mode = "buffers";
    diagnostics = "nvim_lsp";
    indicator.style = null;
    #separatorStyle = "slant";
    closeIcon = "󰅚";
    bufferCloseIcon = "󰅙";
    modifiedIcon = "󰀨";
    offsets = [
      {
        filetype = "neo-tree";
        text = "File Explorer";
        text_align = "center";
        separator = false;
      }
    ];
    highlights = {
      indicatorSelected.fg = "#89b4fa";
      #tabSeparatorSelected.fg = "#89b4fa";
    };
    diagnosticsIndicator = ''
      function(count, level)
        local icon = level:match("error") and " " or ""
        return " " .. icon .. count
      end
    '';
  };
}
