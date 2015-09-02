{ config, pkgs, ... }:

{
  nix.distributedBuilds = true;

  nix.buildMachines = [
    { hostName = "plato.duckdns.org"; maxJobs = 8; sshKey = "/root/.ssh/id_rsa"; sshUser = "leroy"; system = "x86_64-linux"; }
    { hostName = "peaches"; maxJobs = 2; sshKey = "/root/.ssh/id_rsa"; sshUser = "leroy"; system = "x86_64-linux"; }
  ];
}
