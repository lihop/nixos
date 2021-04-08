{ config, pkgs, ... }:

{
  environment.variables = {
    EDITOR = "vim";
  };

  environment.sessionVariables = {
    GTK_DATA_PREFIX = [
      "${config.system.path}"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  time.timeZone = "Asia/Ho_Chi_Minh";

  console = {
    keyMap = "dvp";
    font = "lat9w-16";
  };

  i18n = {
    defaultLocale = "en_NZ.UTF-8";
    inputMethod = {
      enabled = "uim";
    };
  };

  # Currently encountering some ipv6 issues when updating NixOS.
  # Workaround is to add DNS record for nixos cache.
  # See: https://github.com/NixOS/nixpkgs/issues/65015
  networking.extraHosts = ''
    cache.nixos.org CNAME v2.shared.global.fastly.net.
  '';

  environment.systemPackages = with pkgs; [
    borgbackup
    dnsutils
    (import ../pkgs/dotfiles.nix)
    git
    hdparm
    htop
    iotop
    inetutils
    killall
    lsof
    ncdu
    nethogs
    nix-index
    nmap
    patchelf
    pciutils
    powertop
    pwgen
    rxvt_unicode
    smartmontools
    telnet
    tmux
    wakelan
    wget
    wtf
    unzip
    zip
  ];

  programs.ssh.startAgent = true;
  programs.bash.enableCompletion = true;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  services.locate = {
    enable = true;
    interval = "daily";
  };


  services.printing = {
    enable = true;
  };

  users.extraGroups.leroy.gid = 1000;
  users.extraUsers.leroy = {
    isNormalUser = true;
    home = "/home/leroy";
    description = "Leroy Hopson";
    extraGroups = [ "wheel" "leroy" "lp" ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8tOhj726PYsM2w46IPRc+v/NgEhHJjw+VjmEmOHEX3+XhYU8DKvomNWajggpWC9sDhpBDey028Vv25hCY1tin31dwCM6KWeKJ0HIeM4iUbB1w6CwJz+Xee9wmkqRVLd0mH9CgJ9auanY9XWGYiJisG6dR1xVkoF2fDXe+j4VQ4s4Ai5hVCiC1nGq4fxroTOEzUol/mEtmuGZOiYrXj84HycASf1yACu1EhZa9cj6QsEajAT4NKf9+6lnRK6z2UeUvrpeabgJ5JdBTjg454IwfIAtJ5ZQ3h17Zco3uZ6ZGlEjOfPqAssuBTW1tDCNEQVUPFB6zUiXD0N1WvPQ0DtKqmwCpIITKt6jX+BV+hrtB7gp9itByEOFDJqziZjd6EDj8l7O4D/YzSGuPz1xS9NJnb0I7S7WG6ABNm3usDb1ta+ZW5olN+66Wj7aOK+ELDysXLJEKOVLmNtyxNriR7vUxEDsJ7R8PF9KUk9f7RuqLcS4dCKh9V635T6NKHCO3Ru9HdyvHMLhzvAzWdOBkRqIJ8u9wPhDRYdIAHICZdYE3LpY4RcZ2wui8+dt5KplbUbpaOhEc41wfuCaanOXN4HgBuLBcuGBqnAHKmCz5+7x5ePlfokiCLxvOoR3nYywdHKXfhU8Vhw1vpwSyg2j0meL1mI4rdZvm55E3XIgdnU+pXw== leroy@example"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCn9tdOR33GVq+T708WDwsNm0BDH9uAl2MwqGCBU+mHlPTJiToJr8NI2MFO8K7i85HNfG+jXu5nFY10myXRGY/5Mz3qc3jXMt2VTd25q5i7mn1lgTw9YiWcCEoIsn/FGBH2OU7FthfCBKY/vnqBzSK5viVFCFhhHAFWcrrcYjaryu1iVuYWQgw6QCyY4YxU7niDhRoC+ep94Qgsvrof2/pnRJkOVFRKTakqdcUNVfx2VDufFgDgni79fvuSvOMUliiHGEzTb0O95aVjpS0KfRoJTunMYl+kvrFCtLIs4eFPRiChnNkRuECffyFmX2u5ORN9RYoaMCu/1uX0tjbyWNP/bU6YEihofGV+3PiJzgsjb4B7rpNZyxFZAOuL5dONU4ZFNvfSeSNA7pPj8bzoRjfT9DeofAmiJEFcDEywi7+ArSziUKLeU79NHkGDqnIyavxnEerHX8MpcKnDHU9qAU2A/UhbsqqhogGEUgbA713b94ecaaGABl3ZuvxssthHtKar6YIFgfTiwoMjlY72m691xHYRkwUJyjOOgkT5ZdrYzb7zZ3tcPkQSrt6dRVcwvqOnGYDudSTaj/2uAPJeG+YSTbp2qIZaJtgNXRIQqKLgSjUnh1VWxPYy/5Hre1k+GRX+yXg4MfMkP2qsfXoRhb9+AnKQnkAKvmAWk4wvZ6KwrQ== root@ss.nix.nz"
    ];
  };

  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  nix.buildCores = 0;

  # Add acces to the Nix User Repository (NUR) https://github.com/nix-community/NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Use beta v2 binary cache.
  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://aseipp-nix-cache.global.ssl.fastly.net"
  ];
}
