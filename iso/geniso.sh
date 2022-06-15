#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nixos-generators

# Script to generate bootable NixOS installer ISO image.

set -e
cd "$(dirname "$0")"
echo -e "Generating NixOS ISO...\n"
nixos-generate --format iso --configuration ./iso.nix -o result
echo -e "\nISO generated: ./result/iso/$(ls -1 result/iso)"
