# Canonical Nix binary cache configuration, shared by flake.nix nixConfig
# and modules/shared/nix-cache.nix. Keep this the single source of truth.
{
  substituters = [
    # keep-sorted start
    "https://cache.nixos.org"
    "https://eana.cachix.org"
    "https://nix-community.cachix.org"
    # keep-sorted end
  ];
  trusted-public-keys = [
    # keep-sorted start
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "eana.cachix.org-1:3sJHATrL9zjGFGZwAXpECSMR+Ql5k02GgdxfJyzHi84="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # keep-sorted end
  ];
}
