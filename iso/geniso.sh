#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nixos-generators

# Script to generate bootable NixOS installer ISO image.

set -e
start_dir=$(pwd)
cd "$(dirname "$0")"
echo -e "Generating NixOS ISO...\n"
nixos-generate -I nixpkgs=../nixpkgs --format iso --configuration ./iso.nix -o result
echo -e "\nISO generated: ./$(realpath -s --relative-to=${start_dir} ./result/iso/$(ls -1 result/iso))"
if ! find result/iso -name *.iso -size -8000M | grep -q .; then
	echo -e "\033[33mWarning: Image may be too large to fit on an 8GB USB flash drive!\033[0m"
fi
