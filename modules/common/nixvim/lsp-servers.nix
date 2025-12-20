{
  plugins.lsp.servers = {
    nixd.enable = true;
    cssls.enable = true;
    java-language-server.enable = true;
    jsonls.enable = true;
    lua-ls.enable = true;
    rust-analyzer = {
      enable = true;
      installCargo = true;
      installRustc = true;
    };
    yamlls.enable = true;
    efm.enable = true;
  };
}
