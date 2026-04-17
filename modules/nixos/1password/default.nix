{ lib, config, ... }:
let
  cfg = config.darrint.onepassword;
in
{
  options.darrint.onepassword = {
    enable = lib.mkEnableOption "Enable 1Password CLI and GUI";
  };

  config = lib.mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "darrint" ];
    };
  };
}
