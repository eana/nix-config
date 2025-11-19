{ pkgs }:
{
  settings.hooks = {
    check-json.enable = true;
    check-xml.enable = true;
    conform.enable = false;
    end-of-file-fixer.enable = true;
    check-merge-conflict = {
      enable = true;
      entry = "${pkgs.python312Packages.pre-commit-hooks}/bin/check-merge-conflict";
      types = [ "text" ];
    };
  };
}
