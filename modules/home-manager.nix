let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "666eee4f72979b0ebbd2e065a3846d7a8a16895c";
    ref = "master";
  };
in
{
  imports = [ "${home-manager}/nixos" ];
}
