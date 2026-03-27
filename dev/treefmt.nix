{ pkgs }:
{
  programs = {
    # keep-sorted start block=yes
    keep-sorted.enable = true;
    mdformat.enable = true;
    nixfmt = {
      enable = true;
      package = pkgs.nixfmt;
    };
    stylua = {
      enable = true;
      settings = {
        indent_type = "Spaces";
        indent_width = 2;
      };
    };
    # keep-sorted end
  };

  # SKILL.md files contain YAML frontmatter that mdformat misinterprets as
  # horizontal rules and headings.  Exclude them from Markdown formatting.
  settings.formatter.mdformat.excludes = [ "**/SKILL.md" ];
}
