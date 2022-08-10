{ config, lib, modulesPath, ... }:

{
  networking.hostName = "heavy";

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")

      ../hardware/common.nix
      ../roles/common.nix
      ../roles/home-network.nix
    ];

  # Borg backup server for soldier.
  services.borgbackup.repos.soldier = {
    # Allow passwordless SSH key on soldier to append data to the repo for automated backups.
    # Only grant full access using password protected personal SSH key.
    authorizedKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8tOhj726PYsM2w46IPRc+v/NgEhHJjw+VjmEmOHEX3+XhYU8DKvomNWajggpWC9sDhpBDey028Vv25hCY1tin31dwCM6KWeKJ0HIeM4iUbB1w6CwJz+Xee9wmkqRVLd0mH9CgJ9auanY9XWGYiJisG6dR1xVkoF2fDXe+j4VQ4s4Ai5hVCiC1nGq4fxroTOEzUol/mEtmuGZOiYrXj84HycASf1yACu1EhZa9cj6QsEajAT4NKf9+6lnRK6z2UeUvrpeabgJ5JdBTjg454IwfIAtJ5ZQ3h17Zco3uZ6ZGlEjOfPqAssuBTW1tDCNEQVUPFB6zUiXD0N1WvPQ0DtKqmwCpIITKt6jX+BV+hrtB7gp9itByEOFDJqziZjd6EDj8l7O4D/YzSGuPz1xS9NJnb0I7S7WG6ABNm3usDb1ta+ZW5olN+66Wj7aOK+ELDysXLJEKOVLmNtyxNriR7vUxEDsJ7R8PF9KUk9f7RuqLcS4dCKh9V635T6NKHCO3Ru9HdyvHMLhzvAzWdOBkRqIJ8u9wPhDRYdIAHICZdYE3LpY4RcZ2wui8+dt5KplbUbpaOhEc41wfuCaanOXN4HgBuLBcuGBqnAHKmCz5+7x5ePlfokiCLxvOoR3nYywdHKXfhU8Vhw1vpwSyg2j0meL1mI4rdZvm55E3XIgdnU+pXw== leroy@soldier"
    ];
    authorizedKeysAppendOnly = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVjytDjvWOH+92+U487JAvuRIM9/mLSunCZYYmpMplTSOQGHnY07lLIpb/Yl3HjsYyaTM/Y+QvFZh5sBhnUqUnwQlHgvGbmWlrwuKV5rjYQOm2SxYpXdfSJr21D/4qrAU0NYzcvp86SsIVodPRD6b6c6PS96ov1/XRC7rgtGN7S3gYaaMDfsQGuqGCKn0SwvjpOj1eiVj4EAS1TRFh84PhvMQgP3fqejIADIXud8mfagCdd7s9lggAqmzbprx0qAKLFea9jpVdWzkTLpnFymN+sO1PPVuKEgUCbUKgXEMeaW3YKycE0RqDuzYL9s/3+V+xqkGSTa4KuelYwnR0qXBtZ9UAbU79bEhuPt1DMz72cQFiVNgjzMl+paUh/O14lD9oKPLW6OG9yVNL0AfWPztLm3inXu5rTanFftM4BJcfp0ZWMJ8IvZtpyEnL4LJQuu7WfGaEA5iZe5x0HuZyxxJQ4SAgNCIopIN1Xfpi0pQEisM2y0g0M9p6uUhBpT6AUh/5+3hR4xvdOUKZ2J1bSRLhNJbogPrDZvOH+c1ola3Mws8i6s9krq8G5NSHTkHKLFewYje3SQIL+tT64UvfPhVitXNmqv9uWU9wFnxfRHw0T6Vh13foOnvZCZhpy3F1gfUWHRBYO61QtrBnD/hHBx6Vmxb7INAskrhlBTZ3z8Dk4Q== root@soldier"
    ];
  };

  services.avahi.interfaces = [ "bond0" ];
  networking.interfaces.bond0 = {
    macAddress = "14:DA:E9:33:D9:1D";
    wakeOnLan.enable = true;
  };
  networking.bonds.bond0 = {
    interfaces = [ "enp7s0" "wlp0s29u1u2" ];
    driverOptions.mode = "balance-tlb";
  };

  # Filesystem maintenance and optimization.
  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" "/var/lib/borgbackup" ];
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
        spec = "/var/lib/borgbackup";
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

  fileSystems."/var/lib/borgbackup" =
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
  networking.wireless.enable = true;
  nix.settings.max-jobs = lib.mkDefault 4;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "pata_marvell" "xhci_pci" "usbhid" "sd_mod" ];
}
