{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.module.atuin = {
    enable = mkEnableOption "Atuin shell history client";
    package = mkOption {
      type = types.package;
      default = pkgs.atuin;
      defaultText = literalExpression "pkgs.atuin";
      description = "The Atuin package to use for the client";
    };
    sync = {
      enable = mkEnableOption "sync with atuin server";
      address = mkOption {
        type = types.str;
        default = "";
        description = "Atuin server address";
      };
      credentialsFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to decrypted secrets file containing atuin credentials.";
      };
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional Atuin client configuration settings";
    };
  };
}
