{ lib }:
{
  modulesFromDir =
    dir:
    let
      isModuleEntry =
        p:
        let
          full = toString p;
          rel = lib.removePrefix "${toString dir}/" full;
        in
        lib.hasSuffix "/default.nix" full
        && rel != "default.nix"
        && !(lib.hasInfix "/" (lib.removeSuffix "/default.nix" rel));

      toName =
        p:
        let
          full = toString p;
          rel = lib.removePrefix "${toString dir}/" (lib.removeSuffix "/default.nix" full);
          segments = lib.splitString "/" rel;

          kebabToCamel =
            s:
            let
              parts = lib.splitString "-" s;
              head = builtins.head parts;
              tail = builtins.tail parts;
              capitalize = w: (lib.toUpper (lib.substring 0 1 w)) + (lib.substring 1 (lib.stringLength w - 1) w);
            in
            head + lib.concatStrings (map capitalize tail);
        in
        lib.concatStrings (map kebabToCamel segments);
    in
    lib.pipe (lib.filesystem.listFilesRecursive dir) [
      (builtins.filter isModuleEntry)
      (map (p: lib.nameValuePair (toName p) (import p)))
      builtins.listToAttrs
    ];
}
