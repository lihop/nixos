{ modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../hardware/common.nix
    ../roles/common.nix
  ];
}
