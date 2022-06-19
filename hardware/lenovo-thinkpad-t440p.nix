{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [ ./common.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];

  environment.systemPackages = with pkgs; [ libcdio ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking.wireless.enable = true;

  nix.maxJobs = lib.mkDefault 4;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.fprintd.enable = true;
  services.xserver.videoDrivers = [ "intel" ];
}
