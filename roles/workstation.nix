{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    acpi
    asciinema
    bfg-repo-cleaner
    dmenu
    exiftool
    evince
    feh
    figlet
    firefox
    gcolor2
    git-secrets
    gparted
    gnumake
    haskellPackages.xmobar
    imagemagick
    joplin-desktop
    kitty
    moreutils
    mupdf
    ncurses
    neofetch
    ntfsprogs
    pavucontrol
    pdftk
    portfolio
    peek
    scrcpy
    scrot
    spotify
    jmtpfs
    (mutt.override { gpgmeSupport = true; })
    (pass.override { x11Support = false; })
    pinentry-curses
    rclone
    rxvt-unicode-unwrapped
    smplayer
    stow
    toilet
    transmission-gtk
    unrar
    vlc
    xclip
    xdotool
    xorg.xev
    xorg.xkill
    xorg.xmodmap
    xorg.xwininfo
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
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    xkb = {
      layout = "us";
      variant = "dvp";
    };
  };
  services.displayManager.defaultSession = "none+xmonad";

  hardware.pulseaudio.enable = true;
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      aegyptus
      dejavu_fonts
      meslo-lg
      (nerdfonts.override { fonts = [ "Meslo" ]; })
      powerline-fonts
      ubuntu_font_family
    ];
  };

  # Home Manager configuration.
  home-manager.users.leroy = { pkgs, ... }: {
    home.stateVersion = "22.11";
    nixpkgs.config.allowUnfree = true;

    programs.home-manager.path = ../home-manager;

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
        + ":$HOME/development/flutter/bin"
        # Add ruby binaries.
        + ":$HOME/.ruby/bin";

      CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";

      # Install Ruby gems locally. Otherwise an error occurs when Ruby tries
      # to write to the read-only nix store.
      GEM_HOME = "$HOME/.ruby";
    };

    programs.bash = with pkgs; {
      enable = true;

      historyFileSize = 10000000;
      historySize = 10000000;
      historyControl = [ "ignoredups" "ignorespace" ];

      shellAliases = {
        ls = "ls --color=auto";
        lock = "xscreensaver-command --lock";
        nur-build = "nix-build --arg pkgs 'import <nixpkgs> {}' -I nixpkgs=/etc/nixos/nixpkgs";
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

  services.logind.extraConfig = "RuntimeDirectorySize=4G";
}
