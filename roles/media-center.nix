{ config, pkgs, user, ... }:

{
  services.xserver = {
    displayManager.lightdm = {
      enable = true;
      extraConfig =
        let
          displayScript = pkgs.writeShellScriptBin "setup-displays.sh" ''
            ${pkgs.xorg.xrandr}/bin/xrandr \
              --output DP-5 --primary --auto \
              --output HDMI-0 --mode 3840x2160 --rate 120 --right-of DP-5
          '';
        in
        ''
          logind-check-graphical = true

          [Seat:seat0]
          display-setup-script = ${displayScript}/bin/setup-displays.sh
        '';
      greeters.gtk.extraConfig = ''
        active-monitor = 0
      '';
    };
  };

  environment.systemPackages = with pkgs; let
    kodiWrapped = pkgs.symlinkJoin {
      name = "kodi-wrapped";
      paths = [
        (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [
          arteplussept
          dateutil
          joystick
          steam-launcher
          trakt
        ]))
      ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kodi \
          --add-flags "--gl-interface=glx"
      '';
    };
  in
  [
    kodiWrapped
    libcec
    libva-utils
    mediainfo
    read-edid
    vdpauinfo
    wmctrl
  ];

  # Xbox Wireless Controller support.
  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
  boot.extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=Y
  '';
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };
  home-manager.users.${user.name} = { ... }: {
    services.blueman-applet.enable = true;
    dconf.settings."org/blueman/general" = {
      # Disable excessive notifications.
      plugin-list = [ "!ConnectionNotifier" ];
    };
  };

  users.users.${user.name}.extraGroups = [ "transmission" ];
  systemd.tmpfiles.rules = [
    "d /media/transmission/movies 2770 transmission transmission -"
    "d /media/transmission/tv 2770 transmission transmission -"
  ];
  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      incomplete-dir = "/media/transmission";
      download-dir = "/media/transmission/movies";
      download-queue-enabled = false;
      alt-speed-down = 2000;
      alt-speed-up = 500;
      ratio-limit-enabled = true;
    };
  };
}
