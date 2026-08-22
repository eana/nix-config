{ lib, pkgs, ... }:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.module.gpg-agent = {
    enable = mkEnableOption "GPG agent configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.gnupg;
      defaultText = literalExpression "pkgs.gnupg";
      description = "Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Configuration options to pass directly to 'services.gpg-agent'.
      '';
    };
  };
}
