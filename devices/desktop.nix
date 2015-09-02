{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "usbhid" "bcache" ];
  boot.kernelModules = [ "kvm-intel" "pci_stub" ];
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
    "/dev/sde"
    "/dev/sdf"
  ];

  boot.kernelPackages = pkgs.linuxPackages_4_1;

  nixpkgs.config = {
    packageOverrides = pkgs: {
      linux_4_1 = pkgs.linux_4_1.override {
        extraConfig =
          ''
            FHANDLE y
          '';
      };
    };
  };
  
  # Setup crypt devices
  boot.initrd.luks.devices = [
    { name = "sda1"; device = "/dev/disk/by-uuid/b2b8f7d3-817e-451c-b20c-7bb4c0d7d92f"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdb1"; device = "/dev/disk/by-uuid/2256cb31-f2d5-4c88-98f3-820a3135ae27"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdc1"; device = "/dev/disk/by-uuid/f72caf15-669c-42e9-b733-9987e885208d"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdd1"; device = "/dev/disk/by-uuid/9dd0cc35-1a81-45dd-9ffd-1d50835c92cc"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sde1"; device = "/dev/disk/by-uuid/3be7e97e-7e84-4adf-84d5-170419e54d89"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sde2"; device = "/dev/disk/by-uuid/6b55dcf5-cf12-4e9d-9fab-a11429beb3ec"; keyFile = "$PATH/crypto_keyfile.bin"; }
    { name = "sdf1"; device = "/dev/disk/by-uuid/6f43fe93-9be6-44ea-a8d4-3c6592707d0c"; keyFile = "$PATH/crypto_keyfile.bin"; }
  ];

  boot.initrd.extraUtilsCommands = ''
    cp -v /boot/crypto_keyfile.bin $out/bin
  '';

  boot.initrd.preLVMCommands = ''
    # Register the bcache devices
    modprobe bcache
    for dev in /dev/mapper/*; do echo $dev > /sys/fs/bcache/register_quiet; done
  '';

  services.xserver = {
    videoDrivers = [ "ati_unfree" ];
  };
}
