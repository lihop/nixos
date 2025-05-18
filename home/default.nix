{ config, lib, pkgs, ... }:

{
  home = {
    username = "leroy";
    homeDirectory = "/home/leroy";
    sessionVariables = {
      BROWSER = "firefox";
      EDITOR = "vim";
      EM_CACHE = "$HOME/.cache/em-cache";
      PS1 = "[\\u@\\h \\W]\\$ ";
      SCONS_CACHE = "$HOME/.cache/scons-cache";
      VISUAL = "vim";
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [ fcitx5-unikey ];
      settings.inputMethod = {
        GroupOrder."0" = "Default";
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us-dvp";
          DefaultIM = "unikey";
        };
        "Groups/0/Items/0".Name = "keyboard-us-dvp";
        "Groups/0/Items/1".Name = "unikey";
      };
    };
  };

  programs.bash = with pkgs; {
    enable = true;
    historyFileSize = 10000000;
    historySize = 10000000;
    historyControl = [ "ignoredups" "ignorespace" ];
    shellAliases = {
      ls = "ls --color=auto";
      lock = "dm-tool lock";
    };
    initExtra = ''
      set -o vi
  
      # Choose a random color scheme
      # Note: because dotfiles are being handled by stow Xcolors and
      # Xresources are symbolic links, so they need to be handled
      # accordingly when invoking the find and sed commands.
      colorscheme=$(${findutils}/bin/find -L ~/.Xcolors | ${coreutils}/bin/shuf -n 1)
      ${gnused}/bin/sed -i --follow-symlinks "1s|.*|#include \"''${colorscheme}\"|g" ~/.Xresources
      ${xorg.xrdb}/bin/xrdb -merge ~/.Xresources
    '';
  };

  programs.git = {
    enable = true;
    userName = "Leroy Hopson";
    userEmail = "git@leroy.nix.nz";
  };

  programs.home-manager.enable = true;

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ ];
    extraConfig = ''
      set exrc
      set makeprg=scons\ -j12\ platform=x11
      set secure
    '';
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  services.dunst.enable = false;
}
