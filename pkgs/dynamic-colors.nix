with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "dynamic-colors";

  src = fetchFromGitHub {
    owner = "sos4nt";
    repo = "dynamic-colors";
    rev = "35325f43620c5ee11a56db776b8f828bc5ae1ddd";
    sha256 = "1xsjanqyvjlcj1fb8x4qafskxp7aa9b43ba9gyjgzr7yz8hkl4iz";
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/etc/bash_completion.d
    cp -v bin/* $out/bin
    cp -v completions/dynamic-colors.bash $out/etc/bash_completion.d
  '';

}
