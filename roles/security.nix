{ pkgs, user, ... }:

{
  environment.systemPackages = with pkgs; [
    aircrack-ng
    amass
    apktool
    bettercap
    bind
    gdb
    genymotion
    hashcat
    hashcat-utils
    jadx
    man-pages
    metasploit
    nasm
    openssl
    pcapfix
    pixiewps
    reaverwps-t6x
    scrcpy
    tcpdump
    usbutils
    wireshark
    zap
    zzuf
  ];

  programs.wireshark.enable = true;
  users.extraUsers.${user.name}.extraGroups = [ "wireshark" ];
}
