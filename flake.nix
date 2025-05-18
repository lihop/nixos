{
  description = "NixOS configuration";

  inputs = {
    nixpkgs = {
      url = "file:///etc/nixos/nixpkgs?submodules=1";
      type = "git";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    NixVirt = {
      url = "github:AshleyYakeley/NixVirt/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, NixVirt, ... }:
    {
      nixosConfigurations.heavy = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "leroy";
        };
        system = "x86_64-linux";
        modules = [
          ./hosts/heavy.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.leroy = import ./home;
          }
        ];
      };
    };
}
