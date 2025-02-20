{ pkgs }:
{
  programs = {
    nixfmt = {
      enable = true;
      package = pkgs.nixfmt-rfc-style;
    };
    stylua = {
      enable = true;
      package = pkgs.stylua;
      settings = {
        indent_type = "Spaces";
        indent_width = 2;
      };
    };
    mdformat = {
      enable = true;
      package = pkgs.mdformat;
    };
  };
}
