{
  pkgs,
  lib,
  version-check,
}:
{
  settings = {
    package = pkgs.lib.mkForce pkgs.prek;
    hooks = {
      check-json.enable = true;
      check-xml.enable = true;
      conform.enable = true;
      end-of-file-fixer = {
        enable = true;
        excludes = [ "\\.age$" ];
      };
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
      d2-render = {
        enable = true;
        name = "d2-render";
        description = "Render D2 diagrams";
        files = "(^|/)diagrams/.*\\.d2$";
        entry =
          let
            app = pkgs.writeShellApplication {
              name = "d2-render-files";
              runtimeInputs = [ pkgs.d2 ];
              text = ''
                for file in "$@"; do
                  d2 --layout elk --sketch --theme 1 "$file"
                  # d2 writes SVGs with mode 0600; git would flag the mode change.
                  chmod 644 "''${file%.d2}.svg"
                done
              '';
            };
          in
          lib.getExe app;
      };
    };
  };
}
