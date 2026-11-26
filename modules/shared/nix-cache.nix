# Shared Nix binary cache configuration used by all hosts.
# This is a plain system nix module (not a home-manager module.<name>
# module), so it lives under modules/shared, not modules/common.
# Import this module from each host's nix/default.nix.
_:
let
  cache = import ../../nix/cache.nix;
in
{
  nix.settings = {
    inherit (cache) substituters trusted-public-keys;
  };
}
