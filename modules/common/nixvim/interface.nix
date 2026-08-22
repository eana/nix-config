{ lib, ... }:
{
  options.module.nixvim = {
    enable = lib.mkEnableOption "nixvim";

    wrapColumn = lib.mkOption {
      type = lib.types.int;
      default = 80;
      description = "Soft wrap column target.";
    };

    softWrapEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether soft wrapping is enabled by default.";
    };
  };
}
