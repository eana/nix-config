{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode-snip";
  version = "3.0.1";
  src = fetchurl {
    url = "https://registry.npmjs.org/${finalAttrs.pname}/-/${finalAttrs.pname}-${finalAttrs.version}.tgz";
    hash = "sha256-LRR9Xh95M1LK7NxA4YKPMUvShLnVVG0Xt4YQZJt5NkY=";
  };
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/lib/opencode-snip
    cp -r . $out/lib/opencode-snip/
  '';
  meta = {
    description = "OpenCode plugin that prefixes shell commands with snip";
    homepage = "https://github.com/VincentHardouin/opencode-snip";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
