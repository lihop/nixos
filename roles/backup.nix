{ config, pkgs, ... }:

{
  imports = [
    # Enable distributed builds
    #./buildMachines.nix
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
    (import ../pkgs/dynamic-colors.nix)
    git
    haskellPackages.ghc
    haskellPackages.xmonad
    haskellPackages.xmonadContrib
    haskellPackages.xmonadExtras
    (pass.override { withX = true; })
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

  programs.bash.enableCompletion = true;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3IPkKZE8YGtGqhZX0F94paNc3JNCpUKwgmNhK+uEC20q9OL9OXmXWRZ/lNrqFrMOkiwmx0PykpbNk2IYMbWk1m4n/hdC17LFdbc9QcCHDADBnVKJGyDtn6VKz1LivV0w/Z4hc/hQtXJ2AmnFt3HhWZ8RV7om9zvRvibsRsjcSzYu0H3BGEL6LGHHQzk9HxADMoPviXD4xWN14I0BM507Q2jABkY2CfZ/1ttX/PbrfmJYPQi6HWqxUMftk/bPHCeQMqZTf4Hfe2/omB1QaKkTi/uUbuWzoQh9Rwx1x6rMCYq8iMAMHjdwEtoQ4qIVLcgab2NRhOJHAHa7v6qfhLjOX leroy@hilly"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsJ44pUGqS8r73K0UuhTl9S7o2hENdSATug45Vb28UhuuBaiVIF8w0o7Q/sa0DhBowKB26Rre+9GJrvgglh4B3NcF/rlS9sHUAfyaAJ6bmp281buXL3FQEz4jYjfoxgX/n4aTTCfGf27eegQo/BF45aTFZEetcCQLTkh2HeihNOAMf+eUS+hDTdCvMHv2+spo9BTnogbCAy4V3Joka9tc3oskayneeY7vGhPbAMqCrI9mLRWN2f9vu8KEONEoJbhBmk8yoVW0rbICxfzNICWTJUEh4UV4R0We5eS2qhdXjSzVQf/pzQzNlOWkVL+tvi7P3KDFFrBli55qAwpE+y4qW0orao4E4f5bPcHHr5GbDQI5YN+V6DNBjT83S3t3LRafSFLGsLz1WYiAqQynDZbiigC2Kw7jzKWQ20qmwWTBQDfyhQM0JKeoyquEbCjlc7bV8vASJDPPzOe/uAVRC96FuqlGv665y+cpNEyWomFG1AyjzZAhh8e7//4F5bXbb/keQS3wnYXUq6wy0L9KYdhJzlFjySl3muZJnH8IL3vrSrI2tri/SQQwmATIM3NoMd4l9co2opchQkW2XMaVfU7yDdvt5Mkzp9/HqASjmVPW0G+aPokjyb1J+DfboeKAtwcJ/es2aRDNKIPWx2vH5r4/WzRzEgrdtHrwtz1eEN1wKDw== leroy@hilly"
    ];
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
