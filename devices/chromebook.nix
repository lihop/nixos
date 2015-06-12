{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules =
    [ "xhci_hcd"
      "ehci_pci"
      "ahci" "usbhid"
      "usb_storage"
    ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams =
    [ "cryptodisk=/dev/sda2"
      "tpm_tis.force=1"
      "modprobe.blacklist=ehci_hcd,ehci_pci"
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ee17e22d-fa70-4791-a206-bb4ca2c75f50";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/swapfile"; }
    ];

  nix.maxJobs = 2;

  boot.loader.grub.enable = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Setup crypt devices
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda1"; } ];

  # Define which kernel to use
  boot.kernelPackages = pkgs.linuxPackages_testing;

  # Use custom kernel configuration
  nixpkgs.config.packageOverrides = pkgs:
    { linux_testing = pkgs.linux_testing.override {
        extraConfig =
          ''
            CHROME_PLATFORMS y
          '';
      };
    };

  networking.hostName = "hilly";
  networking.hostId = "428f090c";
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
      maxSpeed = "2.0";
      minSpeed = "0.5";
      accelFactor = "0.25";
    };
  };
}
