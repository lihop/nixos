{ pkgs, ... }:
let
  distccNoIPv6 = pkgs.distcc.overrideAttrs (oldAttrs: with pkgs; {
    # Compile distcc without IPv6 support by removing the '--enable-rfc2553' flag,
    # otherwise it will unsuccessfully try to connect to '::1'.
    preConfigure = builtins.replaceStrings [ "--enable-rfc2553" ] [ "" ] oldAttrs.preConfigure;

    buildInputs = oldAttrs.buildInputs ++ [ makeWrapper ];

    postInstall = ''
      # Masquerade as other C/C++ compilers.
      for f in ${clang}/bin/*; do
        ln -s $out/bin/distcc $out/bin/$(basename $f)
      done
      for f in ${gcc}/bin/*; do
        ln -sf $out/bin/distcc $out/bin/$(basename $f)
      done

      # Ensure distcc can still find the original compilers.
      wrapProgram $out/bin/distcc \
        --set PATH=${gcc}/bin:${clang}/bin:$PATH
    '';
  });
in
{
  # Distributed C/C++ compilation.
  environment.systemPackages = with pkgs; [
    distccNoIPv6

    # Compilers.
    clang
    gcc
  ];
  environment.variables = with pkgs; {
    DISTCC_HOSTS = "--randomize soldier.local/12,cpp,lzo heavy.local/4,cpp,lzo spy.local/4,cpp,lzo";
    PATH = "${distccNoIPv6}/bin:$PATH";
  };
  services.distccd = {
    enable = true;
    package = distccNoIPv6;
    openFirewall = true;
    allowedClients = [ "192.168.68.0/24" ];
  };

  # Service discovery.
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  # Traffic shaping.
  services.fireqos = {
    enable = true;
    config = ''
      # Prioritize VNC traffic.
      interface bond0 world bidirectional ethernet input rate 80Mbps output rate 80Mbps
        class vnc input commit 13% output commit 13%
          match port 5899
    '';
  };
}
