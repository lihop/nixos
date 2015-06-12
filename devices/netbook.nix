{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "cryptodisk=/dev/sda1" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Setup crypt devices
  boot.initrd.luks.devices = [ { name = "sda1_crypt"; device = "/dev/sda1"; preLVM = true; } ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6dd3aeae-d49d-43c0-b1fb-5ff4e26b81c6";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/f325e177-a9de-49f4-b999-0646c398e95c"; }
    ];

  nix.maxJobs = 2;

  networking.hostName = "raiden";
  networking.wireless.enable = true;

  environment.systemPackages = with pkgs;
    [ sxhkd
      xlibs.xbacklight
    ];

  services.xserver = {
    displayManager.sessionCommands = ''
      sxhkd &
    '';
    videoDrivers = [ "intel" ];
    synaptics = {
      enable = true;
      twoFingerScroll = true;
    };
  };

}
