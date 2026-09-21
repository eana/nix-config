{
  system ? builtins.currentSystem,
}:
let
  self = builtins.getFlake (toString ../.);
  pkgsInput = self.inputs.nixpkgs;
  b = builtins;
in
self
// {
  inherit b system;
  inherit (pkgsInput) lib;
  pkgs = pkgsInput.legacyPackages.${system};
  inherit (self) inputs;
}
