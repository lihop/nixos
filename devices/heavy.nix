{ config, lib, modulesPath, ... }:

{
  networking.hostName = "heavy";

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")

      ../roles/common.nix
      ../roles/home-network.nix
    ];

  services.avahi.interfaces = [ "bond0" ];
  networking.bonds.bond0 = {
    interfaces = [ "enp7s0" "wlp0s29u1u2" ];
    driverOptions.mode = "balance-tlb";
  };

  # Filesystem maintenance and backup.
  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" "/mnt/backup" ];
  };
  services.beesd.filesystems =
    let
      extraOptions = [
        "--scan-mode"
        "2"
        "--thread-count"
        "1"
        "--loadavg-target"
        "5"
      ];
    in
    {
      root = {
        hashTableSizeMB = 512;
        spec = "/";
        extraOptions = extraOptions;
      };
      backup = {
        hashTableSizeMB = 1024;
        spec = "/mnt/backup";
        extraOptions = extraOptions;
      };
    };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/16bec30e-576f-4271-bf9a-2fd528ebd355";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/5329-EE92";
      fsType = "vfat";
    };

  fileSystems."/swap" =
    {
      device = "/dev/disk/by-uuid/16bec30e-576f-4271-bf9a-2fd528ebd355";
      fsType = "btrfs";
      options = [ "subvol=@swap" ];
    };

  fileSystems."/mnt/backup" =
    {
      device = "/dev/disk/by-uuid/1ab94613-ca1d-4e52-8b7e-76302268b9f2";
      fsType = "btrfs";
    };

  swapDevices = [ ];

  boot.initrd.luks.devices = {
    "crypt1".device = "/dev/disk/by-uuid/8f18715b-e325-4e69-a0bf-51fb7ef7cc61";
    "crypt2".device = "/dev/disk/by-uuid/72c9e093-86a4-4f83-b193-13f8717119bb";
    "crypt3".device = "/dev/disk/by-uuid/1d85804b-4fc7-493d-abdc-5cd626112d78";
  };

  networking.useDHCP = lib.mkDefault true;
  nix.settings.max-jobs = lib.mkDefault 4;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "pata_marvell" "xhci_pci" "usbhid" "sd_mod" ];
}
