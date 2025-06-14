{ fontSize ? 14, pkgs, user, ... }:
let
  xresourcesThemes = pkgs.fetchFromGitHub {
    owner = "MicahSnell";
    repo = "Xresources-themes";
    rev = "0826647c65bd91cfd434eeeedd82f38933ab852e";
    sha256 = "sha256-bP4W9C5rjOKfni4MnGl5trGbzeEtSvjMRHKisKJix8o=";
  };
in
{
  home-manager.users.${user.name} = {
    home = {
      username = user.name;
      homeDirectory = "/home/${user.name}";
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
 
        # Choose a random terminal color scheme.
        colorscheme=$(${findutils}/bin/find -L ${xresourcesThemes} -name '*.Xresources' | ${coreutils}/bin/shuf -n 1)
        ${xorg.xrdb}/bin/xrdb -merge $colorscheme
      '';
    };

    programs.git = {
      enable = true;
      userName = user.fullName;
      userEmail = "git@${user.name}.nix.nz";
      signing = {
        key = "CB4E7DEE";
        signByDefault = true;
      };

      extraConfig = {
        core.editor = "vim";
        push.default = "simple";
        diff.noprefix = false;
        http.postBuffer = 524288000;
      };
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

    xresources.properties = {
      "URxvt.dynamicColors" = true;
      "URxvt.scrollBar" = false;
      "URxvt.saveLines" = 8192;
      "URxvt.font" = "xft:MesloLGS Nerd Font Mono:pixelsize=${toString fontSize}:antialias=true";
      "URxvt.boldFont" = "xft:MesloLGS Nerd Font Mono:style=Bold:pixelsize=${toString fontSize}:antialias=true";
    };
  };
}
