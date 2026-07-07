{ config, inputs, ... }: {
  home-manager = {
    users.jonas = {
      _module.args = {
        sshSecretsPath = config.age.secrets.ssh-hosts.path;
        atuinSecretsPath = config.age.secrets.atuin.path;
      };
      imports = [
        # keep-sorted start
        ../../../home/users/jonas/darwin.nix
        ../../../modules/common/default.nix
        # keep-sorted end
      ];
      home.stateVersion = "26.05";
    };

    extraSpecialArgs = { inherit inputs; };
  };
}
