{ eanaLib, inputs, ... }:
{
  flake.nixosConfigurations.nixbox = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../hosts/nixbox/default.nix
      inputs.disko.nixosModules.disko
      inputs.agenix.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-index-database.nixosModules.nix-index
      # HACK: yaru-theme was removed from nixpkgs unstable (Jul 2026, commit
      # 3991532) because gtk-engine-murrine (GTK2) was removed from nixpkgs.
      # Upstream ubuntu/yaru already dropped GTK2 in v26.10.1 — the removal
      # was overly aggressive. Fix merged to nixpkgs master (PR #547796,
      # Aug 2026) but not yet propagated to nixos-unstable.
      # TODO: Remove this module once pkgs.yaru-theme is available in the
      # tracked nixpkgs rev (check: nix eval nixpkgs#yaru-theme.version).
      {
        nixpkgs.overlays = [
          (final: _: {
            yaru-theme = final.stdenv.mkDerivation {
              pname = "yaru";
              version = "26.10.1";
              src = final.fetchFromGitHub {
                owner = "ubuntu";
                repo = "yaru";
                rev = "50ea18cba78c652e9a5682ec375cbd609dc8aca6";
                hash = "sha256-zbXFHEW83u4WAgc5u94rRT0bLgvtii5V+503aOfF9HU=";
              };
              nativeBuildInputs = with final; [
                glib
                meson
                ninja
                pkg-config
                python3
                sassc
              ];
              buildInputs = with final; [
                gnome-themes-extra
                gtk3
              ];
              propagatedBuildInputs = with final; [
                hicolor-icon-theme
                humanity-icon-theme
              ];
              dontDropIconThemeCache = true;
              postPatch = "patchShebangs .";
              meta = with final.lib; {
                description = "Ubuntu community theme 'yaru' - default Ubuntu theme since 18.10";
                homepage = "https://github.com/ubuntu/yaru";
                license = with licenses; [
                  cc-by-sa-40
                  gpl3Plus
                  lgpl21Only
                  lgpl3Only
                ];
                platforms = platforms.linux;
              };
            };
          })
        ];
      }
    ];

    specialArgs = {
      inherit inputs;
      lib = eanaLib "x86_64-linux";
    };
  };
}
