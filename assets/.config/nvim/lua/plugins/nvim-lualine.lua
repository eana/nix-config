return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      section_separators = "",
      component_separators = "",
      theme = "material",
    },
    sections = {
      -- left
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { "filename" },
      -- right
      lualine_x = { "encoding", "fileformat" },
      lualine_y = { "progress", "location" },
      -- lualine_z = { "location" },
    },
  },
}
