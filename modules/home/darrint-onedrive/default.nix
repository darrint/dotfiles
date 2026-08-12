{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.darrint.onedrive;
in {
  options.darrint.onedrive = {
    enable = lib.mkEnableOption "Enable abraunegg OneDrive client with user monitor service";

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        sync_dir = "~/OneDrive";
        skip_file = "~*|.~*|*.tmp";
      };
      description = ''
        Optional onedrive config key/values written to ~/.config/onedrive/config.
        See https://github.com/abraunegg/onedrive/blob/master/config
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.onedrive = {
      enable = true;
      settings = cfg.settings;
    };

    systemd.user.services.onedrive = {
      Unit = {
        Description = "OneDrive sync client";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor --confdir=%h/.config/onedrive";
        Restart = "on-failure";
        RestartSec = "3";
        RestartPreventExitStatus = "3";
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
