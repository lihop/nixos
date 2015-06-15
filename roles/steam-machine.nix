{ config, pkgs, ... }:

{
  nixpkgs.config = { allowUnfree = true; };
  environment.systemPackages = with pkgs; [ steam ];

  # enable direct rendering for 32 bit applications
  # (required to run steam games on a 64 bit system)
  hardware.opengl.driSupport32Bit = true;
}
