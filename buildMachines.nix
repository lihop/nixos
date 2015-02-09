{ config, pkgs, ... }:

{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "hilly";
      maxJobs = 2;
      sshKey = "/home/nix/.ssh/id_rsa";
      sshUser = "nix";
      system = "x86_64-linux";
    } 
    {
      hostName = "zeno";
      maxJobs = 8;
      sshKey = "/home/nix/.ssh/id_rsa";
      sshUser = "nix";
      system = "x86_64-linux";
    }
  ];
}
