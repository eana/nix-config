{
  system ? builtins.currentSystem,
}:
let
  self = builtins.getFlake (toString ../.);
  pkgsInput = if system == "x86_64-darwin" then self.inputs.nixpkgs-darwin else self.inputs.nixpkgs;
  b = builtins;
in
self
// {
  inherit b system;
  inherit (pkgsInput) lib;
  pkgs = pkgsInput.legacyPackages.${system};
  inherit (self) inputs;
}
