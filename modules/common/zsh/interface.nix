{ lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    ;
in
{
  options.module.zsh = {
    enable = mkEnableOption "Z shell opinionated profile";

    p10kConfigFile = mkOption {
      type = types.nullOr types.path;
      default = ../../../assets/.p10k.zsh;
      description = "Path to the Powerlevel10k configuration file (.p10k.zsh)";
      example = "./assets/.p10k.zsh";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.zsh;
      defaultText = literalExpression "pkgs.zsh";
      description = "Z shell package to use";
    };
  };
}
