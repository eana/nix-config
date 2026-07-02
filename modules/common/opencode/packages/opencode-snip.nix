{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "opencode-snip";
  version = "1.6.1";
  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-FQCXf/QupEa6vb07gpiT5xBUW/Aoj4paedmxoUYz12E=";
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
}
