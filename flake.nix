{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    stylix.url = "github:danth/stylix";
    nixvim.url = "github:nix-community/nixvim";

    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    home-manager-stable.url = "github:nix-community/home-manager?ref=release-23.11";

    hyprland-starter = {
      url = "github:mylinuxforwork/dotfiles";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
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
    in
    {
      packages.${system} = {
        dotfiles = (pkgs.callPackage ./dotfiles {inherit pkgs;});
        darrint-dotfiles2 = (pkgs.callPackage ./dotfiles2 {inherit pkgs;});
        darrint-utils = (pkgs.callPackage ./darrint-utils {inherit pkgs;});
      };
      nixosConfigurations = {
        nixoslaptop = lib.nixosSystem {
          inherit system;
          modules = [
            stylix.nixosModules.stylix
            ./nixoslaptop/configuration.nix
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

