{ config, pkgs, user, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # Support for droidcam.
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback video_nr=10 card_label="AndroidCam" exclusive_caps=1
  '';

  environment.systemPackages = with pkgs; [
    audacity
    audio-recorder
    appimage-run
    (blender.override {
      cudaSupport = true;
    })
    bridge-utils
    calibre
    chromium
    droidcam
    espeak
    ffmpeg
    gcc
    gimp
    gnuradio
    gqrx
    hfsprogs
    jp2a
    krita
    looking-glass-client
    pandoc
    scrcpy
    sdrpp
    spice
    spotifyd
    taskwarrior3
    thunderbird
    transmission_4
    wabt
    weechat
    xscreensaver

    # Latex.
    (texlive.combine {
      inherit (texlive)
        scheme-medium

        # Dependencies of usecases style.
        booktabs
        multirow

        # PlantUML plugin and its dependencies.
        plantuml
        adjustbox
        collectbox
        currfile
        fvextra
        pgfopts
        upquote
        xstring
        ;
    })
  ];

  # Add user to all applicable groups.
  users.users.${user.name}.extraGroups = [ "audio" "plugdev" "usb" ];
  users.groups.plugdev = { };

  # RTLSDR.
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];
  services.udev.packages = [ pkgs.rtl-sdr ];
}
