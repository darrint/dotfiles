{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.limine = {
    enable = true;
    enableEditor = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "nixoslaptop";
  networking.wireguard.enable = true;

  darrint.desktop.enable = true;
  darrint.niri.enable = true;
  darrint.pipewire.enable = true;
  darrint.pipewire.jack = true;
  darrint.podman.enable = true;
  darrint.steam.enable = true;
  darrint.onepassword.enable = true;
  darrint.gaming.enable = true;

  darrint.user.extraGroups = [
    "networkmanager"
    "dialout"
  ];

  # x-plane-11 is a local flake package, so it stays here
  environment.systemPackages = [
    inputs.self.packages.${pkgs.system}.x-plane-11
  ];

  networking.firewall.allowedTCPPorts = [
    8000
    4000
    8080
    8081
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
