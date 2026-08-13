{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.darrint.zellij;
  za = pkgs.writeShellScriptBin "za" ''
    exec ${pkgs.zellij}/bin/zellij attach "$@"
  '';
in {
  options.darrint.zellij = {
    enable = lib.mkEnableOption "Enable zellij and config";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij.enable = true;
    home.file.".config/zellij/config.kdl".source = ./zellij.kdl;
    home.packages = [za];

    programs.bash.initExtra = ''
      _za() {
        local sessions
        sessions="$(${pkgs.zellij}/bin/zellij list-sessions -n -s 2>/dev/null)"
        COMPREPLY=($(compgen -W "$sessions" -- "''${COMP_WORDS[COMP_CWORD]}"))
      }
      complete -F _za za
    '';
    programs.zsh.initContent = ''
      _za() {
        local -a sessions
        sessions=(''${(f)"$(${pkgs.zellij}/bin/zellij list-sessions -n -s 2>/dev/null)"})
        _describe 'session' sessions
      }
      compdef _za za
    '';
    programs.fish.shellInit = ''
      complete -c za -f -a "(${pkgs.zellij}/bin/zellij list-sessions -n -s 2>/dev/null)"
    '';
  };
}
