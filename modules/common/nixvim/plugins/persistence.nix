_:

{
  programs.nixvim = {
    autoCmd = [
      {
        command = "Neotree close";
        event = [ "User" ];
        pattern = [ "PersistenceSavePre" ];
      }
      {
        command = "Neotree";
        event = [ "User" ];
        pattern = [ "PersistenceLoadPost" ];
      }
    ];

    plugins.persistence.enable = true;
  };
}
