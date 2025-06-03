{ lib, pkgs }:

pkgs.ollama.overrideAttrs (_: {
  # Add any package overrides here if needed
  # For example:
  # buildInputs = oldAttrs.buildInputs ++ [ pkgs.someDependency ];

  meta = with lib; {
    description = "Local LLM service with GPU acceleration support";
    homepage = "https://ollama.ai";
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
