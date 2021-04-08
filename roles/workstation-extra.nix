{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    audacity
    audio-recorder
    appimage-run
    blender
    calibre
    chromium
    discord
    espeak
    fahcontrol
    fahviewer
    ffmpeg
    gcc
    gimp
    google-chrome
    hfsprogs
    inkscape
    krita
    libreoffice
    lm_sensors
    nvtop
    pandoc
    (qemu_kvm.override { pulseSupport = true; spiceSupport = true; })
    python3
    python3Packages.virtualenv
    python3Packages.virtualenvwrapper
    scrcpy
    skype
    spice
    spotify
    taskwarrior
    thunderbird
    transmission
    virtmanager
    virtviewer
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

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.docker.storageDriver = "devicemapper";
  virtualisation.docker.listenOptions = [
    "/run/docker.sock" "127.0.0.1:4153"
  ];
  virtualisation.virtualbox = {
    host.enable = true;
  };

  # Enable dconf so that virt-managers settings are saved.
  programs.dconf.enable = true;

  # Add user to all applicable groups.
  users.users.leroy.extraGroups = [ "docker" "libvirtd" "usb" "kvm" "vboxusers" ];
}
