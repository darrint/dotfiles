{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-starter = {
      url = "github:mylinuxforwork/dotfiles";
      flake = false;
    };
  };

  outputs =
    inputs@{
      # self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixoslaptop = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.darrint = import ./darrint-home.nix;
              home-manager.extraSpecialArgs.inputs = inputs;
            }
          ];
        };
      };
    };
}
