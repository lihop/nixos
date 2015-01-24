# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  # Setup crypt devices
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; preLVM = true; } ];
  # Define which kernel to use
  boot.kernelPackages = pkgs.linuxPackages_3_18;
  # Define kernel boot parameters
  boot.kernelParams = [
    "tpm_tis.force=1"
    "modprobe.blacklist=ehci_hcd,ehci_pci"
  ];

  # networking.hostName = "nixos"; # Define your hostname.
  networking.hostId = "428f090c";
  networking.wireless.enable = true;  # Enables wireless.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_NZ.UTF-8";
  };

  time.timeZone = "Pacific/Auckland";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  # Use custom kernel configuration
  nixpkgs.config.packageOverrides = pkgs:
    { linux_3_18 = pkgs.linux_3_18.override {
        extraConfig =
          ''
            CHROME_PLATFORMS y
          '';
      };
    };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # Disable OpenSSH agent use GnuPG agent instead
  programs.ssh.startAgent = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "dvorak";
    displayManager.kdm.enable = true;
    desktopManager.kde4.enable = true;
    videoDrivers = [ "intel" ];
    synaptics = {
      enable = true;
      twoFingerScroll = true;
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
