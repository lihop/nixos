{ username, ... }:

{
  services.displayManager.defaultSession = "none+xmonad";

  services.xserver = {
    enable = true;
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
  };

  home-manager.users.${username} = { lib, osConfig, pkgs, ... }: {
    xsession.enable = true;

    xsession.windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ./xmonad.hs;
    };

    i18n.inputMethod.fcitx5.settings.globalOptions.Behavior = {
      OverrideXkbOption = true;
      CustomXkbOption = osConfig.services.xserver.xkb.options;
    };
  };
}
