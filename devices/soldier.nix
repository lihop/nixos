{ config, pkgs, lib, options, ... }:

{
  networking.hostName = "soldier";

  # Uncomment configs for this device and its roles
  imports =
    [
      ../hardware/acer-predator-helios-300.nix
      (import ../modules/battery-check.nix { inherit pkgs; threshold = 10; })
      ../roles/common.nix
      ../roles/home-network.nix
      ../roles/workstation.nix
      ../roles/workstation-extra.nix
      ../roles/project.nix
      ../roles/security.nix
      ../roles/gaming.nix
    ];

  # WARNING: virbr0 needs to exist (created by starting virt-manager) otherwise
  # the samba share systemd unit will fail.
  services.samba.enable = true;
  services.samba.openFirewall = true;
  services.samba.extraConfig = ''
    interfaces = 192.168.122.0/24 virbr0
    bind interfaces only = yes
    map to guest = bad user
    unix extensions = no
  '';
  services.samba.shares = {
    shared = {
      path = "/home/leroy/vms/shared";
      public = "yes";
      "guest only" = "yes";
      writable = "yes";
      browseable = "yes";
      "force user" = "leroy";
      "follow symlinks" = "yes";
      "wide links" = "yes";
    };
  };

  # Disable Wi-Fi as antenna is contained in the screen which is currently detached.
  # Instead get network connection via internet host device (i.e. spy). eth0 network
  # interface is also broken so use USB ethernet adapter enp0s20f0u1.
  networking.wireless.enable = lib.mkForce false;

  # File system maintenance, optimization, and backup.
  services.borgmatic = {
    enable = false; # Heavy no longer available.
    settings.location = {
      repositories = [ "borg@heavy.local:/var/lib/borgbackup" ];
      source_directories = [ "/home/leroy" ];
      exclude_caches = true;
      exclude_patterns = [
        "*/Desktop"
        "*/.cache"
        "*/.local/share/Steam/steamapps"
      ];
    };
    settings.storage = {
      ssh_command = "ssh -i /root/.ssh/borg_append_id_rsa";
      unknown_unencrypted_repo_access_is_ok = true;
    };
    settings.retention = {
      keep_daily = 1;
      keep_weekly = 4;
      keep_monthly = 12;
      keep_yearly = 10;
    };
  };

  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" "/nix" ];
  };
  services.snapper = {
    cleanupInterval = "1h";
    configs =
      let
        common = {
          EMPTY_PRE_POST_CLEANUP = true;
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 24;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_MONTHLY = 0;
          TIMELINE_LIMIT_YEARLY = 0;
        };
      in
      {
        "root" = common // {
          SUBVOLUME = "/";
        };
        "home" = common // {
          SUBVOLUME = "/home";
          ALLOW_GROUPS = [ "users" ];
        };
      };
  };

  # File systems.
  boot.initrd.luks.devices = {
    "crypt1" = {
      device = "/dev/disk/by-uuid/b17c4918-0988-407b-991f-958528195c8a";
      allowDiscards = true;
    };
    "crypt2" = {
      device = "/dev/disk/by-uuid/1b2d9a22-47be-4d0e-a067-e83ee7663c29";
      allowDiscards = true;
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/3c5792f1-1c5d-4482-9d1c-4282edc505d8";
      fsType = "btrfs";
      options = [ "subvol=@" "noatime" "compress=zstd" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/1D81-48E4";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/a2f56bd3-6fa7-4d83-b394-b3601020042b";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress=zstd" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/3c5792f1-1c5d-4482-9d1c-4282edc505d8";
      fsType = "btrfs";
      options = [ "subvol=@home" "noatime" "compress=zstd" ];
    };

    "/home/.snapshots" = {
      device = "/dev/disk/by-uuid/3c5792f1-1c5d-4482-9d1c-4282edc505d8";
      fsType = "btrfs";
      options = [ "subvol=@home_.snapshots" "noatime" "compress=zstd" ];
    };

    "/.snapshots" = {
      device = "/dev/disk/by-uuid/3c5792f1-1c5d-4482-9d1c-4282edc505d8";
      fsType = "btrfs";
      options = [ "subvol=@.snapshots" "noatime" "compress=zstd" ];
    };

    "/swap" = {
      device = "/dev/disk/by-uuid/a2f56bd3-6fa7-4d83-b394-b3601020042b";
      fsType = "btrfs";
      options = [ "subvol=@swap" "noatime" ];
    };
  };
  swapDevices = [{ device = "/swap/swapfile"; }];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
}
