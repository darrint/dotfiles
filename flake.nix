{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager?ref=release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    authentik-nix.url = "github:nix-community/authentik-nix";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    numtide-ai-tools.url = "github:numtide/nix-ai-tools";
    frc-nix = {
      url = "github:frc4451/frc-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable"; # key change
    };
    # DMS uses nixos-unstable + pinned quickshell; intentionally not following nixpkgs
    dms.url = "github:AvengeMedia/DankMaterialShell";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      channels-config = {
        # Allow unfree packages.
        allowUnfree = true;

        nixpkgs-unstable = {
          input = inputs.nixpkgs-unstable;
        };
      };
      systems.modules.nixos = [
        inputs.sops-nix.nixosModules.sops
        inputs.authentik-nix.nixosModules.default
        inputs.disko.nixosModules.disko
      ];
      homes.modules = [
        inputs.sops-nix.homeManagerModules.sops
      ];
    };
}
