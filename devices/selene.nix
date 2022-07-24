{ pkgs, ... }:

{
  networking.hostName = "selene";

  imports = [
    ../hardware/lenovo-thinkpad-t440p.nix
    (import ../modules/battery-check.nix { inherit pkgs; threshold = 2; })

    # Provide network connectivity to helios via ethernet interface.
    (import ../modules/nixos-router/mkRouter.nix {
      externalInterface = "wlp3s0";
      internalInterface = "enp0s25";
      ipRange = "172.26.15.0/24";
    })

    ../roles/common.nix
    ../roles/symbiosis.nix
  ];

  # Provide monitor for helios using VNC.
  users.users.vnc = {
    isNormalUser = true;
    createHome = false;
    shell = "${pkgs.shadow}/bin/nologin";
  };
  systemd.services.vncviewer = {
    description = "VNC Viewer";
    after = [ "display-manager.service" ];
    serviceConfig = {
      User = "vnc";
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.tigervnc}/bin/vncviewer -AlertOnFatalError=0 -ReconnectOnError=0 172.26.15.2::5899";
      Restart = "always";
      RestartSec = 1;
    };
    wantedBy = [ "default.target" ];
    startLimitIntervalSec = 0;
  };
  boot.blacklistedKernelModules = [ "psmouse" ]; # Completely disable touchpad.
  services.xserver = {
    enable = true;
    windowManager.xmonad = {
      enable = true;
      config = ''
        import XMonad
        main = xmonad $ def { borderWidth = 0 }
      '';
    };
    displayManager = {
      autoLogin = {
        enable = true;
        user = "vnc";
      };
      defaultSession = "none+xmonad";
    };
  };
  environment.variables.XCURSOR_SIZE = "64";
  services.xserver.displayManager.sessionCommands = ''
    if [ ! -z "$DISPLAY" ]; then
      # Prevent screen from sleeping.
      xset s off -dpms

      # Move the mouse cursor to the corner of the screen and hide it.
      ${pkgs.xdotool}/bin/xdotool mousemove_relative 999999 999999
      ${pkgs.unclutter}/bin/unclutter -idle 0 -jitter 999999 &
    fi
  '';
  services.fireqos.enable = true;
  services.fireqos.config = ''
    # Prioritize VNC traffic.
    interface enp0s25 world bidirectional ethernet input rate 1000Mbps output rate 1000Mbps
      class vnc input commit 10% output commit 10%
        match port 5899
  '';
  networking.localCommands = ''
    # Disable TCP segmentation offloading which causes ethernet adapter to hang under high load.
    ${pkgs.ethtool}/bin/ethtool -K enp0s25 tso off
  '';

  users.users.root.openssh.authorizedKeys.keys = [
    # Allow helios root access to this devices root account in order to suspend this
    # device when helios is suspended.
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD6PorE5uGrjGmuxhrN/3Jxlmn/i9mTlFg72dwdTVhDVyHEriJ7GMlHssU0XqmDHi3TAngaULc3D+Km5sYFuGRIAYhcfg8R+lfIqaVvvGm0Ut/MQYQKJvzM49SgFVM5exlknLGtElorhf6x60w1IjkkXhaMWf1Chj47k3mcSsoWodKnAA9DgyFaiIsSKdmW4AuS5WNLo4XpgB9G8RAniAbI0OpNQYgmA/m1ZSBH0I/6DW6x7bta71lYGbGlq4fH+AOPK1eV1PJ/x7G7GdBn2XiZUJ2AaZ2yty0UVOJn+rqJmnjNImXrJMf/vZHtp9QU75VAJfMGo8eT0YxEleyTgHHmj3ReJnrbIRQFA3e2BBR3JtrsyOzw8/RVY1zQKPBpfeXDve5HIX1fb1m996OLQhYqfIJ2Lw6EvSFTWslohhzNp+k5hVHbMBz2Y89YCjtXs4tIKas1+3HcICEbW0AGT/R3PwIWQI/CKM0K6IaENu18IJ07PMtMzCRJxTZPDMwmFvtmSkLftTZBIMp3YHmT1yjmwDI9m79N2OGe/xrwrupRDTLYuTCEhia0zcDWKe3lonlLkVh0uG2j4A6xjZoRM+EmqcuE/IVmqubC6qv7iytqxRocjgul//taWNxRAEavCI6svsRobAC7q9kcG2l+DGcj3AvrSkZEiOJPrVcJSF7gGQ== root@helios"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8tOhj726PYsM2w46IPRc+v/NgEhHJjw+VjmEmOHEX3+XhYU8DKvomNWajggpWC9sDhpBDey028Vv25hCY1tin31dwCM6KWeKJ0HIeM4iUbB1w6CwJz+Xee9wmkqRVLd0mH9CgJ9auanY9XWGYiJisG6dR1xVkoF2fDXe+j4VQ4s4Ai5hVCiC1nGq4fxroTOEzUol/mEtmuGZOiYrXj84HycASf1yACu1EhZa9cj6QsEajAT4NKf9+6lnRK6z2UeUvrpeabgJ5JdBTjg454IwfIAtJ5ZQ3h17Zco3uZ6ZGlEjOfPqAssuBTW1tDCNEQVUPFB6zUiXD0N1WvPQ0DtKqmwCpIITKt6jX+BV+hrtB7gp9itByEOFDJqziZjd6EDj8l7O4D/YzSGuPz1xS9NJnb0I7S7WG6ABNm3usDb1ta+ZW5olN+66Wj7aOK+ELDysXLJEKOVLmNtyxNriR7vUxEDsJ7R8PF9KUk9f7RuqLcS4dCKh9V635T6NKHCO3Ru9HdyvHMLhzvAzWdOBkRqIJ8u9wPhDRYdIAHICZdYE3LpY4RcZ2wui8+dt5KplbUbpaOhEc41wfuCaanOXN4HgBuLBcuGBqnAHKmCz5+7x5ePlfokiCLxvOoR3nYywdHKXfhU8Vhw1vpwSyg2j0meL1mI4rdZvm55E3XIgdnU+pXw== leroy@helios"
  ];

  # File system maintenance.
  services.beesd.filesystems."root" = {
    hashTableSizeMB = 128;
    spec = "UUID=30904bdf-c993-4a01-bfd3-9bd49c6593d9";
  };
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };
  services.fstrim.enable = true;

  # File systems.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/30904bdf-c993-4a01-bfd3-9bd49c6593d9";
      fsType = "btrfs";
      options = [ "subvol=@" "noatime" "compress=zstd" "ssd" "autodefrag" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1767-543D";
      fsType = "vfat";
    };
  };

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
}
