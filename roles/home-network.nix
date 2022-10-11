{ pkgs, config, lib, ... }:
let
  masquerade = with pkgs; program:
    ''
      # Masquerade as other C/C++ compilers.
      for f in ${clang}/bin/*; do
        ln -s $out/bin/${program} $out/bin/$(basename $f)
      done
      for f in ${gcc}/bin/*; do
        ln -sf $out/bin/${program} $out/bin/$(basename $f)
      done
    '';

  distccNoIPv6 = pkgs.distcc.overrideAttrs (oldAttrs: with pkgs; {
    # Compile distcc without IPv6 support by removing the '--enable-rfc2553' flag,
    # otherwise it will unsuccessfully try to connect to '::1'.
    preConfigure = builtins.replaceStrings [ "--enable-rfc2553" ] [ "" ] oldAttrs.preConfigure;

    buildInputs = oldAttrs.buildInputs ++ [ makeWrapper ];

    postInstall = (masquerade "distcc") + ''
      # Ensure distcc can still find the original compilers.
      wrapProgram $out/bin/distcc \
        --set PATH=${gcc}/bin:${clang}/bin:$PATH
    '';
  });

  ccacheMasquerade = pkgs.ccache.overrideAttrs (oldAttrs: with pkgs; {
    buildInputs = oldAttrs.buildInputs ++ [ makeWrapper ];

    postInstall = (masquerade "ccache") + ''
      # Ensure ccache first searches the distcc masquerade directory for the original compilers.
      wrapProgram $out/bin/ccache \
        --set PATH=${distccNoIPv6}/bin:$PATH
    '';
  });
in
{
  # Distributed NixOS builds.
  nix.buildMachines =
    let
      soldier = {
        hostName = "soldier.local";
        system = "x86_64-linux";
        maxJobs = 10;
        speedFactor = 3;
        supportedFeatures = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
      };
      spy = {
        hostName = "spy.local";
        system = "x86_64-linux";
        maxJobs = 2;
        speedFactor = 0;
        supportedFeatures = [ "benchmark" "kvm" "nixos-test" ];
      };
    in
    lib.mkMerge [
      # Ensure device isn't added to itself otherwise it causes a deadlock.
      (lib.mkIf (config.networking.hostName == "soldier") [ spy ])
      (lib.mkIf (config.networking.hostName == "spy") [ soldier ])
    ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.settings.trusted-users = [ "nixbld" ];
  services.openssh.permitRootLogin = "yes";
  users.extraUsers.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD6PorE5uGrjGmuxhrN/3Jxlmn/i9mTlFg72dwdTVhDVyHEriJ7GMlHssU0XqmDHi3TAngaULc3D+Km5sYFuGRIAYhcfg8R+lfIqaVvvGm0Ut/MQYQKJvzM49SgFVM5exlknLGtElorhf6x60w1IjkkXhaMWf1Chj47k3mcSsoWodKnAA9DgyFaiIsSKdmW4AuS5WNLo4XpgB9G8RAniAbI0OpNQYgmA/m1ZSBH0I/6DW6x7bta71lYGbGlq4fH+AOPK1eV1PJ/x7G7GdBn2XiZUJ2AaZ2yty0UVOJn+rqJmnjNImXrJMf/vZHtp9QU75VAJfMGo8eT0YxEleyTgHHmj3ReJnrbIRQFA3e2BBR3JtrsyOzw8/RVY1zQKPBpfeXDve5HIX1fb1m996OLQhYqfIJ2Lw6EvSFTWslohhzNp+k5hVHbMBz2Y89YCjtXs4tIKas1+3HcICEbW0AGT/R3PwIWQI/CKM0K6IaENu18IJ07PMtMzCRJxTZPDMwmFvtmSkLftTZBIMp3YHmT1yjmwDI9m79N2OGe/xrwrupRDTLYuTCEhia0zcDWKe3lonlLkVh0uG2j4A6xjZoRM+EmqcuE/IVmqubC6qv7iytqxRocjgul//taWNxRAEavCI6svsRobAC7q9kcG2l+DGcj3AvrSkZEiOJPrVcJSF7gGQ== root@soldier"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDW5EH1cUTZ8ygn7ZZzTUmyrIe/3fIbeUH8DbzbcvFzGevNOG3RC98UNEs0p8YQ1/r0ZGa71pgzo1EmAWhKkUjhCqAEC5TLycdxrk8zge4dSE4J9vObLiSLSwH2FxBpYOozMODZDaWu/tpULACWpqU8s2cM4+1V7Z3FhvG+KVfNsR2tnrEwe0S6Ub/jvQeUmgSgeXv4phV2oI+Ij9p0AefJ3LjixjpMKjtvSBBt2i/0cRB3XBevPLZJS1N4d4FTAngEca6LViTbUjZg+5yEUjbc+/gdD4X7qFbRvZsNTldKgyj3cmkElVww0FWvCn0szxefLwDFT5/qdxn3gDDpanAuh1JhD/pG3XaOR4GRGckFyWloDeXCOHyT64CIIa5JJcXkpmu14uOzhz4C3X0zSAGlHHMspKSk70JkRNop5jIun3hDtKetMrW3n52MaEvPz6VcfAD38+J0jNxmKqLTZhpBl1dO5L56epVxbRwOuz1eRyDNmkSl4eT/npb2Gmt8tOtE5Zil7aGW/dk2OtkZRRWOl9zSzPpugVU8hTAmC3jlYaW2X7ZQUDqwdSJDaMAgUVI80Yx/EuzChWtavc1RcR6QJaWSau4d+xSqHphpX8eT+k/59yZ4qy7OxKKRXcAMSXgAGBN3qCBDYGoaIzChQyMEw6JDq7AKsqgBx3xLknwp/w== root@spy"
    ];
  };

  # Cached and distributed C/C++ compilation.
  environment.systemPackages = with pkgs; [
    borgbackup
    ccacheMasquerade
    clang
    distccNoIPv6
    gcc
  ];
  environment.variables = with pkgs; {
    DISTCC_HOSTS = "--randomize soldier.local/12,cpp,lzo spy.local/4,cpp,lzo";
    PATH = "${ccacheMasquerade}/bin:${distccNoIPv6}/bin:$PATH";
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
  services.fireqos =
    let
      iface = if (config.networking.hostName == "soldier") then "enp0s20f0u1" else "enp0s25";
    in
    {
      enable = true;
      config = ''
        # Prioritize VNC traffic.
        interface ${iface} world bidirectional ethernet input rate 80Mbps output rate 80Mbps
          class vnc input commit 13% output commit 13%
            match port 5899
      '';
    };
}
