{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "opencode-snip";
  version = "3.0.0";
  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-6tWM2uP6Fw5VIXPk2jrNGwmeiS+kORcmhT3tQa3n/Ec=";
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
