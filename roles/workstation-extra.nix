{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice
    nodejs
    taskwarrior
    transmission
  ];
}
