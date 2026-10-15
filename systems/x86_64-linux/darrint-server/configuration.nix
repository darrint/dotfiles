# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./vaultwarden.nix
    ./caddy.nix
    ./jellyfin.nix
    ./terraria.nix
    ./chore-stars.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "darrint-server";
  networking.wireless.enable = true;

  darrint.user.extraGroups = ["networkmanager" "caddy"];
  darrint.netbird-server.enable = true;
  darrint.podman.enable = true;
  darrint.netbird.useRoutingFeatures = "both";
  darrint.pocket-id.enable = true;
  darrint.hermes-agent.enable = true;

  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.rebootWindow = {
    lower = "03:00";
    upper = "05:00";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    MaxRetentionSec=30day
  '';

  environment.systemPackages = with pkgs; [
    vim
    smartmontools
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}
