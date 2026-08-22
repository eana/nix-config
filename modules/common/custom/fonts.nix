{ lib, ... }:
{
  options.custom.fonts = {
    monospace = lib.mkOption {
      type = lib.types.str;
      default = "MesloLGS NF";
      description = "Monospace font family name used by terminal emulators.";
    };

    monoSize = lib.mkOption {
      type = lib.types.int;
      default = 11;
      description = "Monospace font size in points.";
    };
  };
}
