{
  lib,
  config,
  ...
}:
let
  cfg = config.darrint.zellij;
in
{
  options.darrint.zellij = {
    enable = lib.mkEnableOption "Enable zellij and config";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij.enable = true;
    home.file.".config/zellij/config.kdl".source = ./zellij.kdl;
  };
}
