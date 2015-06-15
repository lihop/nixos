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
    (import ../pkgs/dynamic-colors.nix)
    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
    libreoffice
    (mutt.override { gpgmeSupport = true; })
    (pass.override { x11Support = true; })
    (pkgs.texLiveAggregationFun { paths = [ pkgs.texLive pkgs.texLiveExtra pkgs.texLiveBeamer ]; })
    taskwarrior
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
