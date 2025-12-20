{ config, lib, pkgs, user, ... }:

{
  networking.hostName = "heavy";

  nixpkgs.config.permittedInsecurePackages = [
    "gradle-7.6.6"
  ];

  imports = [
    ../roles/common.nix
    ../roles/home.nix
    ../roles/home-network.nix
    ../roles/workstation
    ../roles/workstation-extra.nix
    ../roles/workstation/hyprland
    ../roles/project.nix
    ../roles/security.nix
    ../roles/media-center.nix
    ../roles/terminal-fun.nix
    ../roles/vm-host.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "uas" "sd_mod" "tpm_crb" ];
  boot.initrd.supportedFilesystems = { bcachefs = true; btrfs = true; };
  # i915-sriov initrd module handled by roles/vm-host.nix
  boot.kernelModules = [ "kvm-intel" "nct6683" "usb_storage" "iwlwifi" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.supportedFilesystems = [ "bcachefs" "btrfs" ];

  # Intel iGPU kernel parameters moved to modules/i915-sriov.nix
  boot.extraModprobeConfig = ''
    options snd-intel-dspcfg dsp_driver=1
  '';
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D868-AD34";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  environment.etc = {
    "projects".text = "1:/home/${user.name}/important";
    "projid".text = "important:1";
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = "performance";
  nix.settings.max-jobs = lib.mkDefault 20;

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    powerManagement.enable = true; # Enable power management for NVIDIA

    # PRIME offload configuration
    # Intel iGPU: Default for most apps, drives both displays
    # NVIDIA RTX 4060: Available for offload rendering
    # Most Vulkan games auto-detect and use NVIDIA
    # For manual control: nvidia-offload <command>
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD driver for Intel QuickSync (Gen 11+)
      intel-compute-runtime # OpenCL for Intel GPU compute
      libva-vdpau-driver # VDPAU backend for legacy apps
      libvdpau-va-gl # VDPAU GL wrapper
    ];
  };

  networking.wireless.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "bcachefs";
  };
  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/ed2b8738-1dc8-4f8a-aa41-54bc928ef6ce";
      randomEncryption.enable = true;
    }
    {
      device = "/dev/disk/by-partuuid/02ce64c3-8550-48f4-98ee-4bbd8e4b11fe";
      randomEncryption.enable = true;
    }
  ];

  services.snapper = {
    configs."home" = {
      ALLOW_GROUPS = [ "users" ];
      EMPTY_PRE_POST_CLEANUP = true;
      FSTYPE = "bcachefs";
      SUBVOLUME = "/home";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 8;
      TIMELINE_LIMIT_DAILY = 5;
      TIMELINE_LIMIT_MONTHLY = 3;
      TIMELINE_LIMIT_YEARLY = 0;
    };
    configs."vms" = {
      ALLOW_GROUPS = [ "users" ];
      FSTYPE = "bcachefs";
      SUBVOLUME = "/home/${user.name}/vms/images";
    };
  };

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  # SMART monitoring for early disk failure detection
  # Scheduled for evening/weekend usage (system shutdown nightly, used outside 9-5 work hours)
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications = {
      wall.enable = true; # Broadcast warnings to all logged-in users
      test = true; # Send test notification on startup
    };
    defaults.monitored = "-a -o on -s (S/../.././19|L/../../6/10)"; # Short test daily 7pm, long test Saturday 10am
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
