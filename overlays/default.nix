{ inputs, ... }:

{
  nixpkgs.overlays = [
    (import ./golden-cheetah.nix { inherit inputs; })
  ];
}
