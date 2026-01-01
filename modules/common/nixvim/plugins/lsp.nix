_:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      # Shell and scripting
      bashls.enable = true;

      # Containers and DevOps
      docker_compose_language_service.enable = true;
      docker_language_server.enable = true;
      helm_ls.enable = true;
      terraformls.enable = true;
      tflint.enable = true;

      # Programming languages
      gopls.enable = true;
      pyright.enable = true;
      lua_ls.enable = true;

      # Configuration and data files
      jsonls.enable = true;
      yamlls.enable = true;
      nixd.enable = true;
    };

    onAttach = ''
      if client.server_capabilities.documentFormattingProvider then
        client.server_capabilities.documentFormattingProvider = false
      end
    '';
  };
}
