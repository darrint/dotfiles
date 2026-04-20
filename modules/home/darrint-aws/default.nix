{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.darrint.aws;
in
{
  options.darrint.aws = {
    enable = lib.mkEnableOption "Enable AWS CLI and companion tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.awscli2
      pkgs.aws-vault
      pkgs.ssm-session-manager-plugin
    ];

    programs.bash.initExtra = ''
      complete -C aws_completer aws
    '';
    programs.zsh.initContent = ''
      complete -C aws_completer aws
    '';
  };
}
