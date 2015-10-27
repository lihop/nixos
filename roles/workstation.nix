{ config, pkgs, ... }:

{
  nixpkgs.config = {
    firefox = {
      enableAdobeFlash = true;
    };
  };

  environment.systemPackages = with pkgs; [
    acpi
    cacert
    dmenu
    mupdf
    firefoxWrapper
    gnupg
    (mutt.override { gpgmeSupport = true; })
    (pass.override { x11Support = true; })
    rxvt_unicode
    stow
    vlc
  ];

  services.xserver = {
    enable = true;
    displayManager.auto.enable = true;
    displayManager.auto.user = "leroy";
    displayManager.sessionCommands =
      ''
        urxvtd -q -f -o
      '';
    desktopManager.xterm.enable = false;
    layout = "us";
    xkbVariant = "dvp";
    windowManager.xmonad.enable = true;
    windowManager.default = "xmonad";
    windowManager.xmonad.enableContribAndExtras = true;
    startGnuPGAgent = true;
  };

  hardware.pulseaudio.enable = true;
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      meslo-lg
      ubuntu_font_family
    ];
  };
}
