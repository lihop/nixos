{ pkgs, user, ... }:
let
  cursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 24;
  };
in
{
  imports = [ ./xmonad ];

  environment.systemPackages = with pkgs; [
    acpi
    alsa-utils
    asciinema
    bfg-repo-cleaner
    brightnessctl
    dmenu
    exiftool
    evince
    feh
    figlet
    firefox
    gcolor3
    golden-cheetah
    git-secrets
    google-chrome
    gparted
    gnumake
    haskellPackages.xmobar
    imagemagick
    joplin-desktop
    kitty
    libreoffice
    lightlocker
    moreutils
    mupdf
    ncurses
    neofetch
    ntfsprogs
    pavucontrol
    pdftk
    portfolio
    peek
    python3
    scrcpy
    scrot
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
    vlc
    xclip
    xdotool
    xorg.xev
    xorg.xkill
    xorg.xwininfo
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
  };
  users.extraUsers.${user.name}.extraGroups = [ "audio" ];

  programs.gnupg.agent.enable = true;
  programs.corectrl.enable = true;
  programs.ssh.setXAuthLocation = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.gtk.cursorTheme = cursor;
    };
    displayManager.sessionCommands = "light-locker --no-late-locking &";

    displayManager.lightdm.extraSeatDefaults = ''
      allow-guest=false
      greeter-show-manual-login=true
      greeter-hide-users=false
      allow-multiple-sessions=true
    '';

    xkb = {
      layout = "us";
      variant = "dvp";

      # Switch Right Alt (Alt_R) to act as ISO_Level3_Shift (AltGr).
      options = "lv3:ralt_switch";
    };
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      aegyptus
      dejavu_fonts
      meslo-lg
      nerd-fonts.meslo-lg
      powerline-fonts
      ubuntu_font_family
    ];
  };

  home-manager.users.${user.name}.home.pointerCursor = cursor // {
    gtk.enable = true;
    x11.enable = true;
  };

  services.logind.extraConfig = "RuntimeDirectorySize=4G";
}
