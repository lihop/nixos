{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../hardware/common.nix
    ../roles/common.nix
  ];

  # Enable cloud-init so ISO can be used with cloud providers (e.g. Vultr).
  services.cloud-init = {
    enable = true;
    btrfs.enable = true;
  };
}
