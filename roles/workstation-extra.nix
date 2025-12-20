{ config, pkgs, user, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    # Add Proton GE for better game compatibility
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
    # Use NVIDIA GPU for all Steam games via PRIME offload
    package = pkgs.steam.override {
      extraEnv = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };
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
    appimage-run
    bridge-utils
    calibre
    chromium
    droidcam
    espeak
    ffmpeg
    gcc
    gimp
    gnuradio
    golden-cheetah
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
