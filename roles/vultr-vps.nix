{ config, pkgs, ... }:
let
  common = (import ./common.nix { config = config; pkgs = pkgs; });
in
{
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  users.extraUsers.root.openssh.authorizedKeys.keys =
    common.users.extraUsers.leroy.openssh.authorizedKeys.keys;
}
