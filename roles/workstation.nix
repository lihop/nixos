{ config, pkgs, ... }:
{
  imports = [ ../home-manager.nix ];

  environment.systemPackages = with pkgs; [
    acpi
    asciinema
    cacert
    dmenu
    evince
    feh
    firefox
    git-secrets
    gnome3.adwaita-icon-theme
    gnome3.gnome-sound-recorder
    haskellPackages.xmobar
    imagemagick
    kitty
    mupdf
    pavucontrol
    peek
    scrcpy
    scrot
    gksu
    jmtpfs
    jrnl
    (mutt.override { gpgmeSupport = true; })
    (pass.override { x11Support = false; })
    rclone
    rxvt_unicode
    stow
    transmission-gtk
    unrar
    vlc
    watson
    xclip
    xdotool
    xorg.xev
    xorg.xkill
    xorg.xmodmap
  ];

  programs.gnupg.agent.enable = true;

  programs.ssh.setXAuthLocation = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      extraSeatDefaults = ''
        [Seat:seat-1]
        xserver-command=/usr/bin/X :1
        xserver-layout=seat-1
      '';
    };
    displayManager.sessionCommands =
      ''
        xmodmap ~/.Xmodmap
      '';
    displayManager.defaultSession = "none+xmonad";
    layout = "us";
    xkbVariant = "dvp";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
  };

  hardware.pulseaudio.enable = true;
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      aegyptus
      dejavu_fonts
      meslo-lg
      noto-fonts-emoji
      ubuntu_font_family
    ];
  };

  # Enable GNOME Keyring.
  services.gnome3.gnome-keyring.enable = true;
  security.pam.services.leroy.enableGnomeKeyring = true;

  # Home Manager configuration.
  home-manager.users.leroy = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    programs.home-manager.path = /home/leroy/home-manager;

    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
      ];
      extraConfig = ''
        set exrc
              set makeprg=scons\ -j12\ platform=x11
        set secure
      '';
    };

    manual.manpages.enable = false;

    home.sessionVariables = {
      BROWSER = "firefox";
      EDITOR = "vim";
      KOPS_STATE_STORE = "s3://k8s-vinmas-vn-state-store";
      PS1 = "[\\u@\\h \\W]\\$ ";
      VISUAL = "vim";

      PATH =
        "$PATH"
        # Add npm binaries.
        + ":$HOME/.npm-packages/bin"
        # Add cargo binaries.
        + ":$HOME/.cargo/bin"
        # Add flutter binaries.
        + ":$HOME/development/flutter/bin";

      CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";

      # Use custom nixpkgs.
      NIX_PATH = "$HOME/:$NIX_PATH";

      # Install Ruby gems locally. Otherwise an error occurs when Ruby tries
      # to write to the read-only nix store.
      GEM_HOME = "$HOME/.ruby";
    };

    programs.bash = with pkgs; {
      enable = true;

      historyFileSize = 1000000;
      historyIgnore = [
        "ls"
        "cd"
        "exit"
      ];

      shellAliases = {
        ls = "ls --color=auto";
        lock = "xscreensaver-command --lock";
        nur-build = "nix-build --arg pkgs 'import <nixpkgs> {}' -I nixpkgs=$HOME/nixpkgs";
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

        PATH=$PATH:$HOME/.npm-packages/bin

        source ~/.tokens

        source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
      '';
    };

    programs.git = {
      enable = true;
      userName = "Leroy Hopson";
      userEmail = "git@leroy.geek.nz";
    };

    manual.html.enable = false;

    services.dunst.enable = false;

    xsession.windowManager.xmonad.config = ../dotfiles/xmonad.hs;
  };
}
