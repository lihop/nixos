{ modulesPath, pkgs, lib, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../hardware/common.nix
    ../roles/common.nix
  ];

  # Disable broken ZFS filesystem support.
  boot.supportedFilesystems.zfs = lib.mkForce false;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
}
