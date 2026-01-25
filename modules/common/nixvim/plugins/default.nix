{ pkgs, ... }:

{
  imports = [
    # keep-sorted start
    ./blink-cmp.nix
    ./bufferline.nix
    ./conform-nvim.nix
    ./copilot.nix
    ./d2.nix
    ./gitsigns.nix
    ./lint.nix
    ./lsp.nix
    ./lualine.nix
    ./mini.nix
    ./snacks-nvim.nix
    ./themery-nvim.nix
    ./treesitter.nix
    ./which-key.nix
    # keep-sorted end
  ];

  programs.nixvim = {
    plugins = {
      # --- UI/UX Enhancements ---
      better-comments.enable = true;
      indent-blankline = {
        enable = true;

        settings = {
          indent.char = "│";
          scope.enabled = false;
        };
      };
      trim.enable = true;
      web-devicons.enable = true;

      # --- Editing Productivity ---
      nvim-autopairs.enable = true;

      # --- Search & Navigation ---
      grug-far = {
        enable = true;
        settings.headerMaxWidth = 80;
      };

      # --- Session/State Management ---
      persistence.enable = true;

      # --- Git Integration ---
      diffview.enable = true;

      # --- Diagnostics & Troubleshooting ---
      trouble.enable = true;

      # --- Lazy Loading/Performance ---
      lz-n.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      undotree
    ];
  };
}
