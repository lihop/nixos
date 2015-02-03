{ config, pkgs, ... }:

{
  # Internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_NZ.UTF-8";
  };

  time.timeZone = "Pacific/Auckland";

  environment.systemPackages = with pkgs; [
    cacert
    git
    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.xmonadContrib
    haskellPackages.xmonadExtras
    vim
    wget
  ];

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      meslo-lg
      ubuntu_font_family
    ];
  };

  # Disable OpenSSH agent use GnuPG agent instead
  programs.ssh.startAgent = false;

  services.xserver = {
    enable = true;
    displayManager.auto.enable = true;
    displayManager.auto.user = "leroy";
    displayManager.sessionCommands =
      ''
        sh /home/leroy/.xsession
      '';
    desktopManager.xterm.enable = false;
    layout = "us";
    xkbVariant = "dvp";
    windowManager.xmonad.enable = true;
    windowManager.default = "xmonad";
    windowManager.xmonad.enableContribAndExtras = true;
    startGnuPGAgent = true;
  };

  virtualisation.docker.enable = true;

  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.leroy = {
    isNormalUser = true;
    home = "/home/leroy";
    description = "Leroy Hopson";
    extraGroups = [ "wheel" ];
    uid = 1000;
  };
}
