# Shared Nix binary cache configuration used by all hosts.
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
