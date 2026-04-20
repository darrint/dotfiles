{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.darrint.kubectl;
in
{
  options.darrint.kubectl = {
    enable = lib.mkEnableOption "Enable kubectl and shell completions";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.kubectl
      pkgs.helm
      pkgs.kubectx
      pkgs.argocd
      pkgs.telepresence2
    ];

    programs.bash.initExtra = ''
      source <(kubectl completion bash)
      source <(helm completion bash)
      source <(argocd completion bash)
      source <(telepresence completion bash)
    '';
    programs.zsh.initContent = ''
      source <(kubectl completion zsh)
      source <(helm completion zsh)
      source <(argocd completion zsh)
      source <(telepresence completion zsh)
    '';
    programs.fish.shellInit = ''
      kubectl completion fish | source
      helm completion fish | source
      argocd completion fish | source
      telepresence completion fish | source
    '';
  };
}
