{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Setup crypt devices
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; preLVM = true; } ];

  # Define which kernel to use
  boot.kernelPackages = pkgs.linuxPackages_3_18;

  # Use custom kernel configuration
  nixpkgs.config.packageOverrides = pkgs:
    { linux_3_18 = pkgs.linux_3_18.override {
        extraConfig =
          ''
            CHROME_PLATFORMS y
          '';
      };
    };

  # Define kernel boot parameters
  boot.kernelParams = [
    "tpm_tis.force=1"
    "modprobe.blacklist=ehci_hcd,ehci_pci"
  ];

  networking.hostName = "hilly";
  networking.hostId = "428f090c";
  networking.wireless.enable = true;

  # Select internationalisation properties.
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
    videoDrivers = [ "intel" ];
    windowManager.xmonad.enable = true;
    windowManager.default = "xmonad";
    windowManager.xmonad.enableContribAndExtras = true;
    synaptics = {
      enable = true;
      twoFingerScroll = true;
      maxSpeed = "2.0";
      minSpeed = "0.5";
      accelFactor = "0.25";
    };
    startGnuPGAgent = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.leroy = {
    isNormalUser = true;
    home = "/home/leroy";
    description = "Leroy Hopson";
    extraGroups = [ "wheel" ];
    uid = 1000;
  };

}
