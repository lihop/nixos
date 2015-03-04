{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [ idea.idea-community
      openjdk8
    ];
}
