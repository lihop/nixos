{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cacert
    evince
    (import ../pkgs/dynamic-colors.nix)
    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.xmonadContrib
    haskellPackages.xmonadExtras
    libreoffice
<<<<<<< HEAD
    (mutt.override { gpgmeSupport = true; })
=======
>>>>>>> fa68cc6011d471b334b381456b7dd2369398185a
    (pass.override { withX = true; })
    taskwarrior
    rxvt_unicode
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
