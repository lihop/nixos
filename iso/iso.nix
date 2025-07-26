{ lib, modulesPath, pkgs, ... }:

{
  _module.args.user = { name = "nixos"; fullName = ""; };

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../roles/common.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_15;

  # Disable broken ZFS filesystem support.
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
