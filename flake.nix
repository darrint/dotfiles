{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs?ref=master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    nixvim.url = "github:nix-community/nixvim";

    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    home-manager-stable = {
      url = "github:nix-community/home-manager?ref=release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-master,
      home-manager,
      nixpkgs-stable,
      home-manager-stable,
      stylix,
      nixvim,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
      lib-stable = nixpkgs-stable.lib;
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
      inputs-stable = {
        inherit self stylix nixvim;
        lib = lib-stable;
        pkgs = pkgs-stable;
        home-manager = home-manager-stable;
      };
      pkgs-master = nixpkgs-master.legacyPackages.${system};
    in
    {
      packages.${system} = {
        darrint-utils = (pkgs.callPackage ./darrint-utils {inherit pkgs;});
      };
      packages.fixed-7zz = pkgs-master._7zz;
      overlays.unstable = final: prev: {
        _7zz = self.packages.fixed-7zz;
      };
      nixosConfigurations = {
        nixoslaptop = lib.nixosSystem {
          inherit system;
          modules = [
            stylix.nixosModules.stylix
            ./nixoslaptop/configuration.nix
            { nixpkgs.overlays = [ self.overlays.unstable ]; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.darrint = import ./darrint-home-gui;
              home-manager.extraSpecialArgs.inputs = inputs;
              home-manager.extraSpecialArgs.localPackages = self.packages.${system};
            }
          ];
        };
        nixos-test = lib.nixosSystem {
          inherit system;
          modules = [
            stylix.nixosModules.stylix
            ./nixos-test/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.darrint = import ./darrint-home;
              home-manager.extraSpecialArgs.inputs = inputs-stable;
              home-manager.extraSpecialArgs.localPackages = self.packages.${system};
            }
          ];
        };
      };
    };
}

