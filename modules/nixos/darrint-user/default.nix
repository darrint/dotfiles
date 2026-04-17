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
      default = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr1N+n9997wxRQ+Ss3oj1Ztg726vSVMelxdoSDkM/kqUL6ylELfyiF6ZYeZbTftd4TzJRW8zloltpVE1GnoaNnm/0clLCtJK6gQRNBKx+JBZaF26WpH0yo+Vt2puvajAchrfpzZl/HqZL5RscY+Gs8hS+u7IfbWQ8o/JhyUsY2rgsPSw58LQS8br22EZAcBCOMLXffer7l5489/g83sTKdgyvW2kWq+E97uMswJ2ytAhNbCdYDIGuceHymIVkNAmJ6FS3ykCiOthYGCNIWReR4VQRMix0wqxxxfXrtSXyYio3lhUTEnA2jWmJiVOfy94vRfkMFopuDOp2nOIxbKJhl"
      ];
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
