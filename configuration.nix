{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Include common configuration.
      ./common.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.extraUtilsCommands = ''
    cp -v /boot/crypto_keyfile.bin $out/bin/
  '';

  # Setup crypt devices
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; preLVM = true; keyFile = "$PATH/crypto_keyfile.bin"; } ];

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

  # Define kernel boot parameters
  boot.kernelParams = [
    "tpm_tis.force=1"
    "modprobe.blacklist=ehci_hcd,ehci_pci"
  ];

  networking.hostName = "hilly";
  networking.hostId = "428f090c";
  networking.wireless.enable = true;

  environment.systemPackages = with pkgs;
    [ sxhkd
    ];

  services.xserver = {
    displayManager.sessionCommands = ''
      sxhkd &
    '';
    videoDrivers = [ "intel" ];
    windowManager.xmonad.enable = true;
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      maxSpeed = "2.0";
      minSpeed = "0.5";
      accelFactor = "0.25";
    };
  };
}
