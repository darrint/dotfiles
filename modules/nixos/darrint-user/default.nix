{ lib, config, ... }:
let
  cfg = config.darrint.user;
in
{
  options.darrint.user = {
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra groups for the darrint user beyond the default wheel group.";
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH authorized keys for the darrint user.";
    };
  };

  config = {
    users.users.darrint = {
      isNormalUser = true;
      extraGroups = [ "wheel" ] ++ cfg.extraGroups;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
