let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "472ca211cac604efdf621337067a237be9df389e";
    ref = "master";
  };
in
{
  imports = [ "${home-manager}/nixos" ];
}
