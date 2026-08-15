{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "opencode-github-copilot-auto-model";
  version = "0.2.0";
  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-1IlIrofqGObNMsuV9WzZ10b9sO2RC6x8oQr0kvPSZQk=";
  };
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/lib/opencode-github-copilot-auto-model
    cp -r . $out/lib/opencode-github-copilot-auto-model/
  '';
  meta = {
    description = "OpenCode plugin exposing GitHub Copilot's auto model routing";
    homepage = "https://github.com/opencode-ai/opencode-github-copilot-auto-model";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
