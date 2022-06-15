{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [
      idea.idea-community
      maven
      oraclejdk8
    ];
}
