{ inputs, ... }: self: super:

{
  kodiPackages = super.kodiPackages // {
    steam-launcher = super.kodiPackages.steam-launcher.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./kodi-steam-launcher-hyprland.patch ];

      propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
        self.jq
        self.hyprland
      ];

      postInstall = (old.postInstall or "") + ''
        # Patch the steam-launcher.sh script with Hyprland-specific paths
        substituteInPlace $out/share/kodi/addons/script.steam.launcher/resources/scripts/steam-launcher.sh \
          --replace "hyprctl " "${self.hyprland}/bin/hyprctl " \
          --replace "| jq " "| ${self.jq}/bin/jq "
      '';
    });
  };
}
