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
    { device = "/dev/disk/by-uuid/694febfa-bcfa-4efc-9b48-cec21cd11698"; 
      fsType = "btrfs";
      options = "subvol=root";
    };

#  swapDevices =
#    [ { device = "/dev/disk/by-uuid/96c21e50-5634-43a0-bdf7-a17fe186f383"; }
#    ];

  nix.maxJobs = 2;

  boot.loader.grub.enable = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.extraUtilsCommands = ''
    cp -v /boot/crypto_keyfile.bin $out/bin/
  '';

  # Setup crypt devices
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda1"; preLVM = true; keyFile = "$PATH/crypto_keyfile.bin"; } ];

  # Define which kernel to use
  boot.kernelPackages = pkgs.linuxPackages_3_18;

  # Use custom kernel configuration
  nixpkgs.config.packageOverrides = pkgs:
    { linux_3_18 = pkgs.linux_3_18.override {
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
