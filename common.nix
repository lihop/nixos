{ config, pkgs, ... }:

{
  imports = [
    # Enable distributed builds
    ./buildMachines.nix
  ];
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
    xclip
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

  services.openssh.enable = true;

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
    group = "leroy";
    extraGroups = [ "wheel" ];
    uid = 1000;
  };
  users.extraGroups.leroy.gid = 1000;

  users.extraUsers.nix = {
    isNormalUser = true;
    home = "/home/nix";
    description = "User for performing distributed builds over ssh";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFCV0ZiUualZyUXk6H6I8nvK0AU7555au2xRMwTIkMdktewZ913Mts8/S9nhxwBcDEMf2ozch0MXdobALo1dCeWCCtIB2+wFPwnUMss6ozqjcVKvkSLob62WHA/MR+WsFAq03KfrtV3CjHbAID10PE78/OOEkRoqVLajEqRZ/kABiFHIYWdOH5RCd42wTfG8JcZA39psSQ998WZ5UwvR40tG/NBg//dFuIZemCVcBAMPyxqHKYXCTK6r9Wr/HHfrqa0ieLBWk4+LqRikHyqrTTMyAubEaoSkUr9gMBscXMTj8V9HyoA5UwO5eHhdgRXiVUL/PeYxOgRbFKV/h8GMP5 nix@hilly"
    ];
  };
  users.extraGroups.nix = {};

  # Auto optimisation of the store might be made default soon.
  # See: https://github.com/NixOS/nix/issues/462
  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  # Use all available CPU cores for builds
  nix.buildCores = 0;
}
