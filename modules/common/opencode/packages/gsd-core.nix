{
  lib,
  stdenvNoCC,
  gsdInput,
}:

# HACK: gsd-core is consumed via the neosam/gsd-flake flake input (gsdInput)
# rather than vendored here — it reuses gsd-flake's hard-won Nix fixes (ADR-457
# build-at-publish TS compile, read-only-store copyFileSync patch, gsd_run
# sh-launcher wrapping, GSD_INSTALLER_MIGRATION_RESOLVE default). This wrapper
# exists solely to expose the opencode *plugin* in package-tree mode
# (IS_PACKAGE_TREE) at a stable path.
#
# The plugin's resolveRepoRoot walks UP from __dirname looking for an ancestor
# containing BOTH hooks/ and gsd-core/. That ancestor is the gsd-core package
# root (lib/node_modules/@opengsd/gsd-core). So this wrapper symlinks that
# whole package root at $out — the plugin must remain at
#   $out/.opencode/plugins/gsd-core.js
# with $out/hooks, $out/gsd-core, $out/commands/gsd, etc. as siblings, or
# resolveRepoRoot fails and IS_PACKAGE_TREE flips to false (losing self-
# registration of commands/agents/skills).
#
# We never invoke the gsd-core installer (gsd-core --opencode): that is what
# requires the read-only-store copyFileSync patch, which is unnecessary for
# plugin-mode. The plugin only reads the store and writes its skills cache to
# ~/.cache/opencode/gsd-skills/ (a writable home path).
#
# TODO: revisit if upstream moves .opencode/plugins/gsd-core.js or renames the
# node_modules package dir.
stdenvNoCC.mkDerivation rec {
  pname = "gsd-core-opencode";
  version = "1.11.0";
  src = gsdInput;
  dontBuild = true;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    # Symlink the whole upstream gsd-core package root at $out so the plugin's
    # resolveRepoRoot finds hooks/ + gsd-core/ and IS_PACKAGE_TREE stays true.
    # .opencode is a dotdir, so the * glob misses it — link it explicitly.
    ln -s $src/lib/node_modules/@opengsd/gsd-core/* $out/
    ln -s $src/lib/node_modules/@opengsd/gsd-core/.opencode $out/.opencode

    # $out/bin is the payload runtime (gsd-tools.cjs, gsd_run, ...). Rebuild it
    # as a real dir re-linking each payload bin so we can also expose the
    # flake package's wrapped gsd-mcp-server without a path collision.
    rm $out/bin
    mkdir -p $out/bin
    ln -s $src/lib/node_modules/@opengsd/gsd-core/bin/* $out/bin/
    ln -s $src/bin/gsd-mcp-server $out/bin/gsd-mcp-server
    runHook postInstall
  '';
  meta = {
    description = "GSD Core opencode plugin + MCP server (via neosam/gsd-flake)";
    homepage = "https://github.com/open-gsd/gsd-core";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
