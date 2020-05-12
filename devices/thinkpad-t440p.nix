{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/84a7b09e-a686-44db-9c57-ecfb13911a49";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."sda2_crypt".device = "/dev/disk/by-uuid/2fa09963-38fc-4ec8-aa21-36120bc1d33b";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/854A-1CD9";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.wireless.enable = true;

  services.xserver = {
    synaptics.enable = true;
    videoDrivers = [ "intel" ];
  };

  services.fprintd.enable = true;

  # Add a cron job to check the battery status and automatically suspend the system
  # when it is critically low.
  services.cron =
    let
      script = with pkgs; writeText "battery-check" ''
        #!/bin/sh
        ${acpi}/bin/acpi -b | ${gawk}/bin/awk -F'[,:%]' '{print $2, $3}' | {
            read -r status capacity

            if [ "$status" = Discharging -a "$capacity" -lt 5 ]; then
                ${busybox}/bin/logger "Critical battery threshold"
                ${systemd}/bin/systemctl suspend
            fi
        }
      '';
    in
    {
      enable = true;
      systemCronJobs = [
        "*/1 * * * * root /bin/sh ${script}"
      ];
    };
}
