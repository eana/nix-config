{ config, pkgs, ... }:

{
  environment.pathsToLink = [ "/Applications" ];

  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = [ "/Applications" ];
      };
    in
    pkgs.lib.mkForce ''
      # Set up system applications.
      echo "setting up /Applications..." >&2
      rm -rf "/Applications/Nix Apps"
      mkdir -p "/Applications/Nix Apps"
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
      # Set up home-manager applications.
      # HACK: home-manager materializes app bundles as real directories (copies),
      # not symlinks, so the previous `find -type l` scan matched nothing and
      # /Applications/Nix Apps stayed empty for every home.packages GUI app.
      # TODO: drop this hand-rolled scan once nix-darwin or home-manager ships an
      # equivalent alias farm for home-manager app bundles.
      hm_apps="${config.users.users.jonas.home}/Applications/Home Manager Apps"
      for app in "$hm_apps"/*.app; do
          [ -e "$app" ] || continue
          echo "copying $app" >&2
          ${pkgs.mkalias}/bin/mkalias "$app" "/Applications/Nix Apps/$(basename "$app")"
      done
    '';
}
