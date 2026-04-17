{ lib, config, ... }:
let
  cfg = config.darrint.steam;
in
{
  options.darrint.steam = {
    enable = lib.mkEnableOption "Enable Steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
