{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aalib.bin
    asciiquarium
    bastet
    bb
    cbonsai
    cmatrix
    cowsay
    figlet
    fortune
    greed
    hollywood
    lolcat
    ninvaders
    moon-buggy
    nyancat
    ponysay
    sl
    toilet
  ];
}
