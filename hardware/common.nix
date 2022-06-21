{ lib, pkgs, modulesPath, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_5_17;
  boot.loader.timeout = lib.mkForce 1;
  boot.kernelParams = [
    "delayacct" # Required by iotop.
  ];
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
}
