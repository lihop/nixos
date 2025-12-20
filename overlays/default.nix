{ inputs, ... }:

{
  nixpkgs.overlays = [
    (import ./golden-cheetah.nix { inherit inputs; })
    (import ./kodi-steam-launcher.nix { inherit inputs; })
  ];
}
