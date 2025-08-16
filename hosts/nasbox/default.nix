{
  imports = [
    ./system/environment.nix
    ./system/packages.nix
    ./system/virtualization.nix
    ./home-manager/default.nix
    ./nix/default.nix
  ];

  time.timeZone = "Europe/Stockholm";
  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = null;
  };

  system.stateVersion = "24.05";
}
