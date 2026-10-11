{ pkgs }:
{
  programs = {
    # keep-sorted start block=yes
    keep-sorted.enable = true;
    mdformat = {
      enable = true;
      plugins = ps: [ ps.mdformat-frontmatter ];
    };
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

  # SKILL.md files are left untouched: mdformat would reflow their bodies and
  # re-serialize their YAML frontmatter (quoting, block scalars). The
  # frontmatter plugin above keeps wiki/ page frontmatter intact.
  settings.formatter.mdformat.excludes = [ "**/SKILL.md" ];
}
