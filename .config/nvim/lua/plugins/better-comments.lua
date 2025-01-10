return {
  {
    "Djancyp/better-comments.nvim",
    config = function(_, opts)
      require("better-comment").Setup(opts)
    end,
    opts = {
      tags = {
        {
          name = "?",
          fg = "cyan",
          bg = "",
          bold = false,
          virtual_text = "",
        },
      },
    },
  },
}
