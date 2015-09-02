{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    libreoffice
    nixopsUnstable
    nodejs
    npm2nix
    (pkgs.texLiveAggregationFun { paths = [ pkgs.texLive pkgs.texLiveExtra pkgs.texLiveBeamer ]; })
    taskwarrior
    transmission
    weechat
    xscreensaver
  ];

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.libvirtd.enable = true;

  # In order to pass USB devices from the host to the guests,
  # the user needs to be in the vboxusers group
  users.extraGroups.vboxusers.members = [ "leroy" ];
}
