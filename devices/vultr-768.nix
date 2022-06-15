{ config, lib, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_blk" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.version = 2;

  fileSystems."/" =
    {
      device = "/dev/vda1";
      fsType = "btrfs";
    };

  swapDevices = [ ];

  nix.maxJobs = 1;
}
