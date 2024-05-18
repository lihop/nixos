{ lib, pkgs, modulesPath, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_9;
  boot.loader.timeout = lib.mkForce 1;
  boot.kernelParams = [
    "delayacct" # Required by iotop.
  ];
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
}
