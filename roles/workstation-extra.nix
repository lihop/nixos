{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    audacity
    audio-recorder
    appimage-run
    blender
    bridge-utils
    calibre
    chromium
    discord
    espeak
    ffmpeg
    gcc
    gimp
    gnuradio
    google-chrome
    gqrx
    hfsprogs
    inkscape
    jp2a
    krita
    libreoffice
    looking-glass-client
    pandoc
    playonlinux
    (qemu_kvm.override { pulseSupport = true; spiceSupport = true; })
    scrcpy
    sdrpp
    skypeforlinux
    spice
    spotify-tui
    spotifyd
    taskwarrior
    thunderbird
    transmission
    vagrant
    (virt-manager.override { spice-gtk = spice-gtk; })
    virt-viewer
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

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "devicemapper";
  virtualisation.docker.listenOptions = [
    "/run/docker.sock"
    "127.0.0.1:4153"
  ];
  virtualisation.podman.enable = true;
  virtualisation.virtualbox = {
    host.enable = true;
  };
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enableNvidia = true;

  # Enable direct rendering for 32 bit applications
  # (required by virtualisation.docker.enableNvidia).
  hardware.opengl.driSupport32Bit = true;

  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 root kvm -"
  ];
  systemd.user.services.scream-ivshmem-pulse = {
    enable = true;
    description = "Scream IVSHMEM pulse receiver";
    unitConfig = {
      After = "pulseaudio.service";
      Wants = "pulseaudio.service";
    };
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        "${pkgs.coreutils-full}/bin/truncate -s 0 /dev/shm/scream-ivshmem"
        "${pkgs.coreutils-full}/bin/dd if=/dev/zero of=/dev/shm/scream-ivshmem bs=1M count=2"
      ];
      ExecStart = "${pkgs.scream}/bin/scream -m /dev/shm/scream-ivshmem";
    };
    wantedBy = [ "default.target" ];
  };

  # Enable dconf so that virt-managers settings are saved.
  programs.dconf.enable = true;

  # Add user to all applicable groups.
  users.users.leroy.extraGroups = [ "docker" "libvirtd" "plugdev" "usb" "kvm" "vboxusers" ];
  users.groups.plugdev = { };

  # RTLSDR.
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];
  services.udev.packages = [ pkgs.rtl-sdr ];
}
