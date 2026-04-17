# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./vaultwarden.nix
    ./caddy.nix
    ./jellyfin.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "darrint-server";
  networking.wireless.enable = true;

  darrint.user.extraGroups = [ "networkmanager" ];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}
