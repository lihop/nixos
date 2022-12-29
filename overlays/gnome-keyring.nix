# Fixes issue where Gnome keyring uses 100% CPU.
# Source: https://github.com/NixOS/nixpkgs/issues/201324#issuecomment-1315825676
# Note: This has already been patched in upstream so we will be able to remove
# this overlay after upgrading nixpkgs some time in the future.
final: prev: {
  gnome = prev.gnome // {
    gnome-keyring = (prev.gnome.gnome-keyring.override {
      glib = prev.glib.overrideAttrs (a: rec {
        patches = a.patches ++ [
          (final.fetchpatch {
            url = "https://gitlab.gnome.org/GNOME/glib/-/commit/2a36bb4b7e46f9ac043561c61f9a790786a5440c.patch";
            sha256 = "sha256-b77Hxt6WiLxIGqgAj9ZubzPWrWmorcUOEe/dp01BcXA=";
          })
        ];
      });
    });
  };
}
