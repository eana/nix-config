# To encrypt a file:
# cat secrets/ssh-hosts.nix | nix run .#agenix -- -e secrets/ssh-hosts.age
let
  # ssh user keys
  jonas-macbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhkZXZS9kncETCALGhU4mKrooISoYsaSrMPYBf4ss7v";
  jonas-nasbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeDavVuEljfsfBMW90Gy///+pERcQP20++fAFbFksdx";
  jonas-nixbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+qpCo4eLhdNH32FORP21FzrDizHK7krsaFU3Naxxtn";
  jonas-oldbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQbkQjVrARK5CI74PvEYXI3UCicE0nwiMYShOl4P31e";

  # ssh host keys
  macbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILiXjg7W4r7OFBQ0Av7rysETgvJNZdcaxWXtQ5gfHq7r";
  nasbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICc5dgjlWWmoXG4gBYDy2mozfWSIErmtKVAgRP6XpAgs";
  nixbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWvSi5GNjd3TqP0hX1tqZmEFgtCDJnPZ5ymXFe0k9lP";
  oldbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYdM304AQ1hLve1bnEFf139KlvI9cVKrOPGNibG1A4O";

  allSystems = [
    macbox
    nasbox
    nixbox
    oldbox
  ];
  allUsers = [
    jonas-macbox
    jonas-nasbox
    jonas-nixbox
    jonas-oldbox
  ];
in
{
  "secrets/ssh-hosts.age".publicKeys = allUsers ++ allSystems;
}
