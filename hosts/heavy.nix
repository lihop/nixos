{ config, lib, pkgs, user, ... }:

{
  networking.hostName = "heavy";

  imports = [
    ../roles/common.nix
    ../roles/home.nix
    ../roles/home-network.nix
    ../roles/workstation
    ../roles/workstation-extra.nix
    ../roles/project.nix
    ../roles/security.nix
    ../roles/media-center.nix
    ../roles/vm-host
  ] ++ [
    ../modules/deduplication.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "tpm_crb" ];
  boot.initrd.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" ];
  boot.initrd.supportedFilesystems = { bcachefs = true; };
  boot.kernelModules = [ "kvm-intel" "nct6683" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "bcachefs" ];
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
  '';
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  deduplication = {
    enable = false;
    paths = [ /etc /home/${user.name} /media /root /var ];
  };

  environment.etc = {
    "projects".text = "1:/home/${user.name}/important";
    "projid".text = "important:1";
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = "performance";
  nix.settings.max-jobs = lib.mkDefault 20;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };

  networking.wireless.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "bcachefs";
  };
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
  services.snapper = {
    configs."home" = {
      ALLOW_GROUPS = [ "users" ];
      EMPTY_PRE_POST_CLEANUP = true;
      FSTYPE = "bcachefs";
      SUBVOLUME = "/home";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 8;
      TIMELINE_LIMIT_DAILY = 3;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };
  services.borgbackup.jobs.borgbase = {
    compression = "auto,lzma";
    encryption.mode = "repokey-blake2";
    encryption.passCommand = "cat /home/${user.name}/important/passphrase";
    environment.BORG_RSH = "ssh -oBatchMode=yes -i /home/${user.name}/.ssh/borg_rsa";
    paths = [ "/home/${user.name}/important" ];
    repo = "yjr2w9pc@yjr2w9pc.repo.borgbase.com:repo";
    startAt = "daily";
  };

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
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
