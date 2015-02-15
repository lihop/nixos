{ config, pkgs, ... }:

{
  # Uncomment the configuration file for this specefic device.
  imports =
    [ # Device: 
        #./devices/chromebook.nix
        #./devices/desktop.nix
        #./devices/homeserver.nix
      # Roles:
        #./roles/common.nix
        #./roles/server.nix
        #./virtualisation.nix
        #./roles/workstation.nix
    ];
}
