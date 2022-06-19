{ pkgs, ... }:

{
  nixpkgs.config = { allowUnfree = true; };

  hardware.opengl.enable = true;

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
    protontricks
    libva
    openmw
    xboxdrv
    xorg.xf86inputjoystick
  ];

  # Enable jack support.
  hardware.pulseaudio.package = pkgs.pulseaudio.override { jackaudioSupport = true; };

  # Enable direct rendering.
  hardware.opengl.driSupport = true;

  # enable direct rendering for 32 bit applications
  # (required to run steam games on a 64 bit system)
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
}
