{ config, pkgs, inputs, lib, options, ... }:
let
  secretPath = "${inputs.secrets}/scout.nix";
  hasSecrets = builtins.pathExists "${inputs.secrets}/scout.nix";
in
{
  networking.hostName = "scout";

  imports = [
    ../roles/common.nix
    ../roles/home-network.nix
    ../roles/workstation
    ../roles/project.nix
  ] ++ [
    (import ../modules/battery-check.nix { inherit pkgs; threshold = 10; })
    ../modules/deduplication.nix
  ] ++ (if hasSecrets then [ secretPath ] else [ ]);

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # File systems.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/9cbbd68f-ca8c-4ae6-8038-0393c991bf89";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/F48B-6060";
      fsType = "vfat";
    };
  };
  swapDevices = [{ device = "/dev/disk/by-uuid/a626169d-3071-4ea3-85f1-23877e012494"; }];

  # Bootloader.
  boot.initrd.luks.devices."root_crypt".device = "/dev/disk/by-uuid/e09eeee9-fb96-4838-88c3-d9d36f79f1e7";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  services.printing.enable = true;

  programs.adb.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Update this value to match the release version
  # of the first install of this system. Before changing this value read the
  # documentation for this option (e.g. man configuration.nix or on
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  home-manager.users.leroy = { ... }: {
    home.stateVersion = "23.11";
  };
}
