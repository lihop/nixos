let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "5427f3d1f0ea4357cd4af0bffee7248d640c6ffc";
    ref = "master";
  };
in
{
  imports = [ "${home-manager}/nixos" ];
}
