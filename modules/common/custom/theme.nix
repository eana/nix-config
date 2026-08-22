{ lib, ... }:
{
  options.custom.theme = lib.mkOption {
    type = lib.types.enum [
      "gruvbox"
      "tokyo-night"
    ];
    default = "tokyo-night";
    description = "Global colorscheme applied to all visual tools (nixvim, kitty, foot, waybar, opencode tui).";
  };
}
