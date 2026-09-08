{
  lib,
  pkgs,
}:
{
  nixd = {
    command = [ (lib.getExe pkgs.nil) ];
    extensions = [ ".nix" ];
  };

  jsonls = {
    command = [
      (lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server")
      "--stdio"
    ];
    extensions = [
      ".json"
      ".jsonc"
    ];
  };

  yamlls = {
    command = [
      (lib.getExe pkgs.yaml-language-server)
      "--stdio"
    ];
    extensions = [
      ".yaml"
      ".yml"
    ];
  };

  gopls = {
    command = [ (lib.getExe pkgs.gopls) ];
    extensions = [
      ".go"
      ".mod"
      ".sum"
    ];
  };

  bashls = {
    command = [
      (lib.getExe pkgs.bash-language-server)
      "start"
    ];
    extensions = [
      ".sh"
      ".bash"
    ];
  };

  biome = {
    command = [
      (lib.getExe pkgs.biome)
      "lsp-proxy"
    ];
    extensions = [
      ".js"
      ".ts"
      ".jsx"
      ".tsx"
    ];
  };
}
