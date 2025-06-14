{ config, lib, ... }:

{
  # Distributed NixOS builds.
  nix.buildMachines =
    let
      heavy = {
        hostName = "heavy.local";
        system = "x86_64-linux";
        maxJobs = 1;
        protocol = "ssh-ng";
        speedFactor = 4;
        supportedFeatures = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
        mandatoryFeatures = [ ];
      };
      scout = {
        hostName = "scout.local";
        system = "x86_64-linux";
        maxJobs = 1;
        protocol = "ssh-ng";
        speedFactor = 3;
        supportedFeatures = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
        mandatoryFeatures = [ ];
      };
    in
    lib.mkMerge [
      # Ensure device isn't added to itself otherwise it causes a deadlock.
      (lib.mkIf (config.networking.hostName == "heavy") [ scout ])
      (lib.mkIf (config.networking.hostName == "scout") [ heavy ])
    ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.settings.trusted-users = [ "nixbld" ];
  services.openssh.settings.PermitRootLogin = "yes";
  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3vX240xHvbt4jqPu4wcxJvwn8YL9JM3Dja9kNcxgSY8kB0OCANfARC1Q0NZh7h0ovlGgfOfcyBYYWOYcLyhu1NVabpv/t9bNUCb+ZKB6KeidqWIxEAORD8G2jUty8Z+rRmwNckdOhY1LCkdo/m6CktP6URdZ4wwnHN9mOl+0uNRvQd+ZD36GK2f9YCELRkCXH02UjqIrN2kcllwjzhUdbTAVxrCqBU83IFLBPma9nqacaoxoNzoX7lY/856jY+qW0wY4kD+lw1WepqEZEJqh9pb1n35/5ckmHg4u+4Y/TnNuLPQfppSHBVwEjLdWRqqKSGGNxunjtl6TH2vh+JGuNQjCP00ef0zKUcTUYu0dYboCqKWqgAJjQ+yg/moLx5GBXOs4AEoN5aDKUBC1omayI9Panxq0CBQjGQbdp2CJ8ZZKwTb0GT5hWr/MVw/yQamWlBBFWCFtKgYI+7P6irAdtokgfljd2XT6XiCwqYVJY3tJeqOJZThOppmbI5zPIDOEEH5oneX/qDiBJw8Gm6KXqDZ0O966k2hsoQcOYaDVfvbUt/SmiD2FQB+sWBrEeny3nlIf9aiZaPzQpDV4jcUFq7Ilw5PNfX4vH8i3xcanSy012l2MIEFBliR21GRgovoqzIZmKDm4Io0PspGrDrr6cBmCVbxu7+9ubORepnKRi+w== root@heavy"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeU++0D3/el64ukXUHwyAsLh+YqGD3zpV/fItHnu9jJOe6qsl5gma14yx+VLo2GwClV8VpGkCEG9ni+urn7rK47G7CckZczo/EuEFjaHG0bFPDe3rp+XTEFnXnHpORpPDWms06aeMcZ7K3EsCLhDVo4F6glZyMbT/jkXIp5QtpftG/uJaW2vMS5+vsbPlIBexT3EpnXrhqspCPXi2eU/ZWb9SfvC5Sk65MqD9oZ+Ofq+GTsH5vbLu5QOmvrqeI425VecpAElofWwWcoy4trnuJcckqkKtK2nlmz6HSNnH7bfnCsStMyI1sFOgAbJ651ySHdAwMfXuGeAo4GhEob5qpAspEEcusJBeAs1YyC6yrEpc6Ppqu/frNXJ3eCnJjNLxw7fSAUWf+fGPVVhvdnZuJ2KS+2cIucpiJpJmVmcMA8Q3q1irQpBXDqfu3DXM42RRC+t/LJEpWlYovaKMjDAgbzZohO1sWV5q7FCJKzP0JIWuArnm+UAtTeRuh+VY7zskL9TtsZXp7gDew3fN8v6awnKJ4E6oJUDuZfqtD44d6ZCWUNLqxQAU1/HtmnwPBQnXTyl/BdRupI/6YE2nDEuUcfy6C6XcZC1HOSUwCcwDpCiILIpqYMSC4g4Y6/0UjLkKpQ1R8zu3CQn6g3Ck8RRYsROkYmYcHheu8loxIY0Rl1Q== root@scout"
  ];

  # Service discovery.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };
}
