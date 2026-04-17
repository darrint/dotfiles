{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.darrint.podman;
in
{
  options.darrint.podman = {
    enable = lib.mkEnableOption "Enable podman with docker compat";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = with pkgs; [
      cachix
      dive
      podman-tui
      docker-compose
      podman-compose
    ];
  };
}
