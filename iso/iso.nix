{ lib, modulesPath, pkgs, ... }:

{
  _module.args.user = { name = "nixos"; fullName = ""; };
  _module.args.kernelPackages = pkgs.linuxPackages_6_18;

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../roles/common.nix
  ];

  boot.kernelParams = [ "nomodeset" ];
  boot.supportedFilesystems.bcachefs = true;
  boot.supportedFilesystems.btrfs = true;

  # Disable broken ZFS filesystem support.
  boot.supportedFilesystems.zfs = lib.mkForce false;
}
