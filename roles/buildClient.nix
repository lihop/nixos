{ config, pkgs, ... }:

{
  nix.distributedBuilds = true;

  nix.buildMachines = [
    { hostName = "zeno"; maxJobs = 8; sshKey = "/root/.ssh/id_rsa"; sshUser = "leroy"; system = "x86_64-linux"; }
    { hostName = "peaches"; maxJobs = 2; sshKey = "/root/.ssh/id_rsa"; sshUser = "leroy"; system = "x86_64-linux"; }
  ];
}
