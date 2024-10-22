{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    stylix.url = "github:danth/stylix";

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
      stylix,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
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
              home-manager.users.darrint = import ./nixoslaptop/darrint-home.nix;
              home-manager.extraSpecialArgs.inputs = inputs;
              home-manager.extraSpecialArgs.localPackages = self.packages.${system};
            }
          ];
        };
      };
    };
}

