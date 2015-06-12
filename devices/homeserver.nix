{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_hcd" "ehci_pci" "ahci" "usbhid" "usb_storage" "bcache" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2c4644b7-1aa7-4793-aed6-8584eae9138b";
      fsType = "btrfs";
      options = "subvol=root";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/cc28c218-54e0-46cf-92c4-255025d55ba3";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4286f02c-ae9c-465f-90c7-27b61da86857"; }
    ];

  nix.maxJobs = 2;

  boot.loader.grub.enable = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdc";

  networking.bridges.br0.interfaces =
    [ "enp1s0"
      "enp3s0"
      "enp4s0"
    ];
  networking.firewall.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_3_18;

  nixpkgs.config = {
    packageOverrides = pkgs:
    { linux_3_18 = pkgs.linux_3_18.override {
      extraConfig =
        ''
          FHANDLE y
        '';
      };
    };
  };
  
  # Setup crypt devices
  boot.initrd.luks.devices = [
    { name = "luksroot"; device = "/dev/vg0/bcache"; preLVM = false; }
    { name = "boot"; device = "/dev/vg0/boot"; preLVM = false; }
  ];

#  boot.initrd.extraUtilsCommands = ''
#    cp -v /boot/crypto_keyfile.bin $out/bin
#  '';

  boot.initrd.preLVMCommands = ''
    modprobe bcache
    for dev in /dev/sd*; do echo $dev > /sys/fs/bcache/register_quiet; done
  '';
}
