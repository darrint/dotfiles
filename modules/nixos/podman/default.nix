{ lib, config, ... }:
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
  };
}
