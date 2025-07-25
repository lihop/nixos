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

    secrets = {
      url = "path:/home/leroy/nixos/secrets";
      flake = false;
    };

    NixVirt = {
      url = "github:AshleyYakeley/NixVirt/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, NixVirt, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      commonConfig = {
        system = system;
        specialArgs = {
          inherit inputs;
          fontSize = 14;
          kernelPackages = pkgs.linuxPackages_6_15;
          user = { name = "leroy"; fullName = "Leroy Hopson"; };
        };
        modules = [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          (import ./overlays { inherit inputs; })
        ];
      };
    in
    {
      nixosConfigurations.heavy = nixpkgs.lib.nixosSystem (commonConfig // {
        modules = commonConfig.modules ++ [ ./hosts/heavy.nix ];
      });
      nixosConfigurations.scout = nixpkgs.lib.nixosSystem (commonConfig // {
        modules = commonConfig.modules ++ [ ./hosts/scout.nix ];
        specialArgs = commonConfig.specialArgs // { fontSize = 16; };
      });
    };
}
