{
  lib,
  pkgs,
  stdenvNoCC,
  fetchFromGitHub,
  uv,
  makeWrapper,
}:

stdenvNoCC.mkDerivation rec {
  pname = "garmin-mcp-auth";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "Taxuspt";
    repo = "garmin_mcp";
    rev = "655efb8f5639602f661c26164282d0ddd4f5d3db";
    hash = "sha256-EhiJOcQfhYjccFkIfywhdcmKbmmT2Kd112gjLkbQA8Q=";
  };
  nativeBuildInputs = [
    uv
    makeWrapper
  ];
  dontBuild = true;
  installPhase = ''
    ${uv}/bin/uv --cache-dir "$TMPDIR/uv-cache" pip install --only-binary cryptography --python ${pkgs.python3} --target $out/lib $src
    makeWrapper ${pkgs.python3}/bin/python3 $out/bin/garmin-mcp-auth \
      --add-flags "-m garmin_mcp.auth_cli" \
      --prefix PYTHONPATH : $out/lib
  '';
  meta = {
    description = "Pre-authentication CLI for Garmin MCP server";
    homepage = "https://github.com/Taxuspt/garmin_mcp";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "garmin-mcp-auth";
  };
}
