{ config, pkgs, lib, options, ... }:

{
  networking.hostName = "helios";

  # Uncomment configs for this device and its roles
  imports =
    [
      ../hardware/acer-predator-helios-300.nix
      (import ../modules/battery-check.nix { inherit pkgs; threshold = 10; })
      ../roles/common.nix
      ../roles/workstation.nix
      ../roles/workstation-extra.nix
      ../roles/project.nix
      ../roles/security.nix
      ../roles/gaming.nix
    ];

  # Currently laptop screen is broken (i.e. completely detached) therefore we use
  # a secondary laptop as monitor via VNC.
  systemd.user.services.x11vnc = {
    description = "X11 VNC";
    after = [ "display-manager.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -clip xinerama1 -forever -repeat -noxdamage -cursor -multiptr -nonap -allow 172.26.15.1";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };
  services.xserver.displayManager.autoLogin = { enable = true; user = "leroy"; };
  networking.firewall.interfaces.enp0s20f0u1.allowedTCPPorts = [ 5900 ];
  networking.extraHosts = ''
    # Add VNC client to hosts file.
    172.26.15.1 selene
  '';
  powerManagement.powerDownCommands = ''
    # Suspend VNC client along with VNC host.
    ${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=no 172.26.15.1 systemctl suspend
  '';
  powerManagement.resumeCommands = ''
    # When VNC host resumes wake the client using Wake-on-LAN.
    echo "Check connection to VNC client..."
    while ! ${pkgs.iputils}/bin/ping -c 1 -W 1 172.26.15.1; do
      echo "Sending magic packet to wake VNC client..."
      ${pkgs.wakelan}/bin/wakelan 68:F7:28:A3:2B:04
      sleep 1
    done
  '';
  services.xserver.displayManager.setupCommands = ''
    # Set output mode to match VNC client screen resolution.
    # Might not work if the monitor is phyiscally connected and the connected screens
    # EDID does not support the given resolution.
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --mode 1600x900 || true
  '';
  services.xserver.screenSection = ''
    # Ensure monitor is always considered connected (even if it physically isn't)
    # so we can use it for VNC.
    Option "ConnectedMonitor" "HDMI-0"
  '';

  # Disable Wi-Fi as antenna is contained in the screen which is currently detached.
  # Instead get network connection via VNC client device (i.e. selene). eth0 network
  # interface is also broken so use USB ethernet adapter enp0s20f0u1.
  networking.wireless.enable = lib.mkForce false;
  networking.interfaces.enp0s20f0u1.ipv4.addresses = [{
    address = "172.26.15.2";
    prefixLength = 24;
  }];
  networking.defaultGateway.address = "172.26.15.1";

  # File system maintenance and backup.
  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" "/nix" ];
  };
  services.beesd.filesystems =
    let
      common = { extraOptions = [ "--scan-mode" "2" "--thread-count" "1" "--loadavg-target" "5" ]; };
    in
    {
      root = common // {
        hashTableSizeMB = 1024;
        spec = "UUID=3c5792f1-1c5d-4482-9d1c-4282edc505d8";
      };
      nix = common // {
        hashTableSizeMB = 128;
        spec = "UUID=a2f56bd3-6fa7-4d83-b394-b3601020042b";
      };
    };
  services.snapper = {
    cleanupInterval = "8h";
    configs =
      let
        extraConfig = ''
          TIMELINE_CREATE=yes
          TIMELINE_CLEANUP=yes
          TIMELINE_LIMIT_HOURLY=8
          TIMELINE_LIMIT_DAILY=7
          TIMELINE_LIMIT_MONTHLY=3
          TIMELINE_LIMIT_YEARLY=3
        '';
      in
      {
        "root" = {
          subvolume = "/";
          inherit extraConfig;
        };
        "home" = {
          subvolume = "/home";
          extraConfig = extraConfig + ''
            ALLOW_USERS=leroy
          '';
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
