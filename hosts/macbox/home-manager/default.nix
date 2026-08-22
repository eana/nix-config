{
  config,
  inputs,
  lib,
  ...
}:
{
  home-manager = {
    users.jonas = {
      _module.args = {
        sshSecretsPath = config.age.secrets.ssh-hosts.path;
        atuinSecretsPath = config.age.secrets.atuin.path;
      };
      imports = [
        ../../../home/users/jonas/darwin.nix
        inputs.nixvim-darwin.homeModules.nixvim
      ]
      ++ builtins.attrValues (lib.eana.modulesFromDir ../../../modules/common);
      home.stateVersion = "26.05";
      home.enableNixpkgsReleaseCheck = false;

      # Load-bearing: nixvim's module defaults nixpkgs.source to
      # inputs.nixpkgs (main unstable, 26.11) regardless of which nixvim
      # branch we use. Must force it to nixpkgs-darwin (26.05) for macbox.
      programs.nixvim.nixpkgs.source = lib.mkForce inputs.nixpkgs-darwin;
    };

    extraSpecialArgs = {
      inherit inputs;
      nixvimInput = inputs.nixvim-darwin;
    };
  };
}
