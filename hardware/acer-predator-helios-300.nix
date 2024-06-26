{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ./common.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Fix graphical corruption on suspend/resume.
  hardware.nvidia.powerManagement.enable = true;

  networking.wireless.enable = true;

  nix.settings.max-jobs = lib.mkDefault 12;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.libinput.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  virtualisation.kvmgt = {
    enable = true;
    vgpus."i915-GVTg_V5_4" = {
      uuid = [ "3c4064e6-b99a-11ec-8278-6fd71a6313e8" ];
    };
  };
}
