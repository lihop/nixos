let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "51e44a13acea71b36245e8bd8c7db53e0a3e61ee";
    ref = "master";
  };
in
{
  imports = [ "${home-manager}/nixos" ];
}
