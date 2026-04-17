{ lib, config, ... }:
let
  cfg = config.darrint.steam;
in
{
  options.darrint.steam = {
    enable = lib.mkEnableOption "Enable Steam";
    sunshine = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Sunshine game streaming alongside Steam.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    services.sunshine = lib.mkIf cfg.sunshine {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
