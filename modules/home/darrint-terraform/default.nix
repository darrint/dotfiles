{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.darrint.terraform;
in
{
  options.darrint.terraform = {
    enable = lib.mkEnableOption "Enable Terraform";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.terraform ];

    programs.bash.initExtra = ''
      complete -C terraform terraform
      alias tf=terraform
    '';
    programs.zsh.initContent = ''
      complete -C terraform terraform
      alias tf=terraform
    '';
    programs.fish.shellInit = ''
      terraform -install-autocomplete 2>/dev/null; true
      alias tf=terraform
    '';
  };
}
