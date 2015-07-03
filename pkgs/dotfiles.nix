with import <nixpkgs> {};

stdenv.mkDerivation rec {
  version = "1.0";
  name = "dotfiles-${version}";

  src = fetchFromGitHub {
    owner = "lihop";
    repo = "dotfiles";
    rev = "v${version}";
    sha256 = "0nvggfkrxwkq5rhz2anp62z7aasa6qhmaawpvrbf8lmhjmmlkhxd";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp dotfiles-update $out/bin 
  '';

}
