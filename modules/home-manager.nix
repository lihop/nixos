let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "f3a451216628661ec537bbed1365e7d4eeea6e44";
    ref = "release-24.05";
  };
in
{
  imports = [ "${home-manager}/nixos" ];
}
