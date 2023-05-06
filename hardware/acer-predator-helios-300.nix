{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ./common.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Fix graphical corruption on suspend/resume.
  hardware.nvidia.powerManagement.enable = true;

  networking.wireless.enable = true;

  nix.settings.max-jobs = lib.mkDefault 12;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.xserver = {
    libinput.enable = true;
    videoDrivers = [ "nvidia" ];
  };

  virtualisation.kvmgt = {
    enable = true;
    vgpus."i915-GVTg_V5_4" = {
      uuid = [ "3c4064e6-b99a-11ec-8278-6fd71a6313e8" ];
    };
  };
}
