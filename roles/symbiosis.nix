{ pkgs, ... }:
let
  # Compile distcc without IPv6 support by removing the '--enable-rfc2553' flag,
  # otherwise it will unsuccessfully try to connect to '::1'.
  distccNoIPv6 = pkgs.distcc.overrideAttrs (oldAttrs: {
    preConfigure = builtins.replaceStrings [ "--enable-rfc2553" ] [ "" ] oldAttrs.preConfigure;
  });
in
{
  environment.systemPackages = with pkgs; [
    distccNoIPv6

    # Compilers.
    clang
    gcc
  ];
  environment.variables = {
    CC = "distcc";
    CXX = "distcc g++";
    DISTCC_HOSTS = "--randomize soldier,cpp,lzo spy,cpp,lzo";
  };
  services.distccd = {
    enable = true;
    package = distccNoIPv6;
    openFirewall = true;
    allowedClients = [ "127.0.0.1" "172.26.15.0/30" ];
  };
}
