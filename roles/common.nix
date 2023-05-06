{ config, pkgs, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
  ];
  environment.etc.gitconfig.text = "[safe]\n\tdirectory = /home/leroy/nixos/nixpkgs\n";

  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "1.1.1.1"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
    "ns1.digitalocean.com"
  ];

  environment.variables = {
    EDITOR = "vim";
  };

  environment.wordlist.enable = true;

  environment.sessionVariables = {
    GTK_DATA_PREFIX = [
      "${config.system.path}"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  time.timeZone = "Pacific/Auckland";

  console = {
    keyMap = "dvorak-programmer";
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
    acpi
    binutils
    borgbackup
    cacert
    dnsutils
    (import ../pkgs/dotfiles.nix)
    entr
    ethtool
    file
    git
    hdparm
    htop
    iftop
    iotop
    iperf
    inetutils
    jq
    killall
    linuxPackages.usbip
    lm_sensors
    lsof
    mtr
    ncdu
    nethogs
    nix-index
    nix-output-monitor
    nixpkgs-fmt
    nmap
    ntfs3g
    p7zip
    patchelf
    pciutils
    powertop
    pv
    pwgen
    python
    rxvt-unicode-unwrapped
    smartmontools
    speedtest-cli
    socat
    sysbench
    tmux
    vim
    wakelan
    wget
    wtf
    unzip
    usbutils
    zip
  ];

  environment.interactiveShellInit = ''
    alias freeze='sync && echo freeze | sudo tee /sys/power/state'
  '';

  programs.ssh.startAgent = true;
  programs.bash.enableCompletion = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  users.extraGroups.leroy.gid = 1000;
  users.extraUsers.leroy = {
    isNormalUser = true;
    home = "/home/leroy";
    description = "Leroy Hopson";
    extraGroups = [ "wheel" "leroy" "lp" ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8tOhj726PYsM2w46IPRc+v/NgEhHJjw+VjmEmOHEX3+XhYU8DKvomNWajggpWC9sDhpBDey028Vv25hCY1tin31dwCM6KWeKJ0HIeM4iUbB1w6CwJz+Xee9wmkqRVLd0mH9CgJ9auanY9XWGYiJisG6dR1xVkoF2fDXe+j4VQ4s4Ai5hVCiC1nGq4fxroTOEzUol/mEtmuGZOiYrXj84HycASf1yACu1EhZa9cj6QsEajAT4NKf9+6lnRK6z2UeUvrpeabgJ5JdBTjg454IwfIAtJ5ZQ3h17Zco3uZ6ZGlEjOfPqAssuBTW1tDCNEQVUPFB6zUiXD0N1WvPQ0DtKqmwCpIITKt6jX+BV+hrtB7gp9itByEOFDJqziZjd6EDj8l7O4D/YzSGuPz1xS9NJnb0I7S7WG6ABNm3usDb1ta+ZW5olN+66Wj7aOK+ELDysXLJEKOVLmNtyxNriR7vUxEDsJ7R8PF9KUk9f7RuqLcS4dCKh9V635T6NKHCO3Ru9HdyvHMLhzvAzWdOBkRqIJ8u9wPhDRYdIAHICZdYE3LpY4RcZ2wui8+dt5KplbUbpaOhEc41wfuCaanOXN4HgBuLBcuGBqnAHKmCz5+7x5ePlfokiCLxvOoR3nYywdHKXfhU8Vhw1vpwSyg2j0meL1mI4rdZvm55E3XIgdnU+pXw== leroy@soldier"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCSezdp5bQHgf+LJU37QGjgTaD/+ZLR1zgdoSVPx7woUN4xCJcMV/edHJ4T6aEeg1XoNHExlqltBpQFmO8enwCGEfLP4vhYy/kXxUtsxNoQ/4AO5kCjyklPTVTXyMYgnznS5i/0XIQDtQRquzFpCOikFRFaoJkWFdxpIeoT1cAK/TWjaXa9QU43vUD5WZ3W2ec6+f9CLPoYyer31/hFokxYGOC2UM+1vMtMC95zq5/qmRaCp8eWlsBvKL4zsyWI3bqDv3cqFTIkSljh6VhOh4gzjMHpFYIe4U3E9hr0LY8Sxq2pqYlUgaVbE3Ym5cmyp7v3nYU4WmdMJeSPFrGCS1yo8tYa+TH0peA3tdNLvL4mEzJu8kwBbefiHxEm09OfWyYpqOg14SrcJCAzdrvVAvK4A9eS48qfIR6CIKWWWU9OFiNfMkS4n6X5F96+hmp+vvV8XtmuDYyiE9JqV94Y0LAJ2pZKHfDllAUOn5WjmS5mjb9wu/r78f6APlnZfVSgSoJPT5FFfdyf1z0XC0hh0I1PTLfBX0QHtA9j5Y2HnWmjlV6RpMf1Kd8CBeDl88/ouws2qCBfaELL9/q3XKR0Yq3rt7NGXMRq2tU/7sCeSPpwyVq+GiBBuRLO4JtwP8PV8IxO4v++4eEAlU7/tpzX1izLMYoPo+jSmCOfBNDYF8a73Q== leroy@scout"
    ];
  };

  nix.extraOptions = ''
    auto-optimise-store = true
  '';

  nix.settings = {
    cores = 0;
    sandbox = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Add acces to the Nix User Repository (NUR) https://github.com/nix-community/NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
