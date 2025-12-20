{ pkgs, user, ... }:
let
  cursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 24;
  };
in
{
  imports = [
    #./xmonad
    ../../modules/hyprland-workspace-audio.nix
  ];

  # Enable automatic workspace-based audio routing
  services.hyprland-workspace-audio.enable = true;

  environment.systemPackages = with pkgs; [
    acpi
    alsa-utils
    asciinema
    bfg-repo-cleaner
    brightnessctl
    intel-gpu-tools # Provides intel_gpu_top for monitoring Intel GPU
    # dmenu  # X11-only - use rofi-wayland or fuzzel for Wayland
    exiftool
    evince
    # feh  # X11 image viewer - use imv for Wayland
    figlet
    firefox
    gcolor3
    git-secrets
    google-chrome
    gparted
    gnumake
    # haskellPackages.xmobar  # X11-only status bar
    imagemagick
    joplin-desktop
    kitty
    libreoffice
    # lightlocker  # X11 screen locker - use swaylock for Wayland
    moreutils
    mupdf
    ncurses
    ntfsprogs
    pavucontrol
    pdftk
    portfolio
    peek
    python3
    scrcpy
    # scrot  # X11 screenshot tool - use grim+slurp for Wayland
    spotify
    jmtpfs
    (mutt.override { gpgmeSupport = true; })
    (pass.override { x11Support = false; })
    pinentry-curses
    rclone
    rxvt-unicode-unwrapped
    smplayer
    stow
    toilet
    transmission_4-gtk
    unrar
    # VLC with VA-API hardware decode enabled
    (pkgs.symlinkJoin {
      name = "vlc-vaapi";
      paths = [ pkgs.vlc ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/vlc \
          --add-flags "--avcodec-hw=vaapi"
      '';
    })
    # xclip  # X11 clipboard - use wl-clipboard for Wayland
    # xdotool  # X11 automation - use ydotool for Wayland
    # xorg.xev  # X11 event viewer - use wev for Wayland
    # xorg.xkill  # X11 utility
    # xorg.xwininfo  # X11 utility
    yt-dlp
  ];

  # Audio.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber = {
      enable = true;
      extraConfig = {
        "10-disable-devices".monitor.alsa.rules = [
          {
            matches = [{ "device.name" = "alsa_card.pci-0000_04_00.1"; }];
            actions.update-props = { "device.disabled" = true; };
          }
          {
            matches = [
              { "node.name" = "alsa_output.pci-0000_01_00.1.pro-output-7"; }
              { "node.name" = "alsa_output.pci-0000_01_00.1.pro-output-8"; }
              { "node.name" = "alsa_output.pci-0000_01_00.1.pro-output-9"; }
            ];
            actions.update-props = { "node.disabled" = true; };
          }
          {
            matches = [{ "node.name" = "~alsa_output.pci-0000_00_1f.3.*hdmi.*"; }];
            actions.update-props = { "node.disabled" = true; };
          }
        ];

        "11-set-profiles"."monitor.alsa.rules" = [
          {
            matches = [{ "device.name" = "alsa_card.pci-0000_00_1f.3"; }];
            actions.update-props = { "device.profile" = "output:analog-stereo"; };
          }
          {
            matches = [{ "device.name" = "alsa_card.pci-0000_01_00.1"; }];
            actions.update-props = { "device.profile" = "output:hdmi-stereo"; };
          }
        ];
      };
    };
  };
  users.extraUsers.${user.name}.extraGroups = [ "audio" ];

  programs.gnupg.agent.enable = true;
  programs.corectrl.enable = true;
  # programs.ssh.setXAuthLocation = true;  # X11 forwarding - not needed for Wayland

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Greetd display manager with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  # XKB configuration for console (before login)
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "dvp";
      options = "lv3:ralt_switch";
    };
  };

  #
  # Old LightDM config (replaced by greetd)
  #
  #services.xserver = {
  #  enable = true;
  #  displayManager.lightdm = {
  #    enable = true;
  #    greeters.gtk.cursorTheme = cursor;
  #  };
  #  displayManager.sessionCommands = "light-locker --no-late-locking &";

  #  displayManager.lightdm.extraSeatDefaults = ''
  #    allow-guest=false
  #    greeter-show-manual-login=true
  #    greeter-hide-users=false
  #    allow-multiple-sessions=true
  #  '';

  #  xkb = {
  #    layout = "us";
  #    variant = "dvp";

  #    # Switch Right Alt (Alt_R) to act as ISO_Level3_Shift (AltGr).
  #    options = "lv3:ralt_switch";
  #  };
  #};

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      aegyptus
      dejavu_fonts
      meslo-lg
      nerd-fonts.meslo-lg
      powerline-fonts
      ubuntu-classic
    ];
  };

  home-manager.users.${user.name} = {
    home.pointerCursor = cursor // {
      gtk.enable = true;
      # x11.enable = true;  # Not needed for Wayland-only setup
    };

    # Disable systemd integration when using UWSM (as recommended by NixOS wiki)
    wayland.windowManager.hyprland.systemd.enable = false;

    # Kitty terminal configuration
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
      };
    };
  };

  services.logind.settings.Login.RuntimeDirectorySize = "4G";
}
