{ pkgs, version-check }:
{
  settings.hooks = {
    check-json.enable = true;
    check-xml.enable = true;
    conform.enable = false;
    end-of-file-fixer.enable = true;
    version-check = {
      enable = true;
      entry = "${version-check}/bin/version-check --hook";
      pass_filenames = false;
      always_run = true;
      stages = [ "pre-push" ];
    };
    check-merge-conflict = {
      enable = true;
      entry = "${pkgs.python312Packages.pre-commit-hooks}/bin/check-merge-conflict";
      types = [ "text" ];
    };
  };
}
