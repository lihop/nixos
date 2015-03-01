{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "usbhid" "bcache" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/bcache0";
      fsType = "btrfs";
      options = "subvol=root";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/d2086f17-b0a4-480e-b8d9-21dd320abcbf";
      fsType = "ext4";
    };

  fileSystems."/var/lib/docker/btrfs" =
    { device = "/root/var/lib/docker/btrfs";
      fsType = "none";
      options = "bind";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/586fa43b-fa17-4738-9f06-7aac331e8321"; }
    ];

  nix.maxJobs = 8;

  boot.loader.grub.enable = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [
    "/dev/sda"
    "/dev/sdb"
    "/dev/sdc"
    "/dev/sdd"
    "/dev/sde"
    "/dev/sdf"
  ];

  boot.kernelPackages = pkgs.linuxPackages_3_18;

  nixpkgs.config = {
    allowUnfree = true;
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
    { name = "sda1"; device = "/dev/sda1"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdb1"; device = "/dev/sdb1"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdc1"; device = "/dev/sdc1"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdd1"; device = "/dev/sdd1"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sde1"; device = "/dev/sde1"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sde2"; device = "/dev/sde2"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdf1"; device = "/dev/sdf1"; keyFile = "$PATH/crypto_keyfile.bin"; }
  ];

  boot.initrd.extraUtilsCommands = ''
    cp -v /boot/crypto_keyfile.bin $out/bin
  '';

  boot.initrd.preLVMCommands = ''
    modprobe bcache
    for dev in /dev/mapper/*; do echo $dev > /sys/fs/bcache/register_quiet; done
  '';

  networking.hostName = "zeno";
  networking.hostId = "4f5b35ed";
  networking.wireless.enable = false;

  services.xserver = {
    videoDrivers = [ "ati_unfree" ];
  };
}
