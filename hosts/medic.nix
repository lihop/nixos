{ config, lib, pkgs, user, ... }:

{
  networking.hostName = "medic";

  imports = [
    ../roles/common.nix
    ../roles/home.nix
    ../roles/home-network.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "tpm_crb" "e1000e" "r8169" ];
  boot.initrd.supportedFilesystems = { bcachefs = true; };
  boot.initrd.network = {
    enable = true;
    flushBeforeStage2 = true;
    ssh = {
      enable = true;
      port = 22;
      authorizedKeys = config.users.users.${user.name}.openssh.authorizedKeys.keys;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
  };
  boot.initrd.systemd =
    let
      askPass = pkgs.writeShellScriptBin "bcachefs-askpass" ''
        systemctl start sysroot.mount
      '';
    in
    {
      enable = true;
      storePaths = [ "${askPass}/bin/bcachefs-askpass" ];
      users.root.shell = "${askPass}/bin/bcachefs-askpass";
      network = {
        enable = true;
        networks."10-eth" = {
          matchConfig.Name = "eth* enp* eno*";
          address = [ "192.168.1.126/24" ];
          gateway = [ "192.168.1.254" ];
        };
      };
    };
  boot.kernelModules = [ "kvm-intel" "nct6683" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "bcachefs" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  networking.wireless.enable = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "bcachefs";
  };

  powerManagement.cpuFreqGovernor = "powersave";
  services.thermald.enable = true;

  # Disable GPU.
  systemd.services.disable-nvidia-gpu = {
    description = "Remove NVIDIA GPU from PCI bus";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "disable-gpu" ''
        echo 1 > /sys/bus/pci/devices/0000:01:00.1/remove || true
        echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove || true
      '';
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Update this value to match the release version
  # of the first install of this system. Before changing this value read the
  # documentation for this option (e.g. man configuration.nix or on
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  home-manager.users.${user.name} = { ... }: {
    home.stateVersion = "24.11";
  };
}
