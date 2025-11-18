# To encrypt a file:
# cat secrets/ssh-hosts.nix | nix run .#agenix -- -e secrets/ssh-hosts.age
let
  jonas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+qpCo4eLhdNH32FORP21FzrDizHK7krsaFU3Naxxtn";

  nixbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKWvSi5GNjd3TqP0hX1tqZmEFgtCDJnPZ5ymXFe0k9lP";
  macbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGy2X2QDJBna7Ao5aGci6xe9qkccX7RxOV9bE6zdy3j";
  nasbox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICc5dgjlWWmoXG4gBYDy2mozfWSIErmtKVAgRP6XpAgs";

  allSystems = [
    nixbox
    macbox
    nasbox
  ];
  allUsers = [ jonas ];
in
{
  "secrets/ssh-hosts.age".publicKeys = allUsers ++ allSystems;
}
