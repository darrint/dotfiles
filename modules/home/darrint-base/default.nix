{
  pkgs,
  inputs,
  ...
}: {
  home.stateVersion = "24.11";
  home.packages = [
    pkgs.killall
    pkgs.nixfmt
    pkgs.devenv
    pkgs.lolcat
    pkgs.figlet
    pkgs.dig
    pkgs.wget
    pkgs.strace
    pkgs.python3
    pkgs.jq
    pkgs.curl
    pkgs.cachix
    pkgs.uv
    inputs.numtide-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.herdr
  ];

  # Let Home Manager install and manage itself.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.nushell.enable = true;
  programs.direnv.enable = true;
  programs.eza.enable = true;

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
      ServerAliveInterval = 60;
      ServerAliveCountMax = 3;
      ControlMaster = "auto";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "10m";
    };
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
    };
  };
  programs.zoxide.enable = true;
  programs.mcfly.enable = true;
  programs.fastfetch.enable = true;
  programs.nh.enable = true;
  programs.htop.enable = true;
  programs.btop.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.fzf.enable = true;

  darrint.git.enable = true;
  darrint.kubectl.enable = true;
  darrint.aws.enable = true;
  darrint.oci.enable = true;
  darrint.terraform.enable = true;
  darrint.zellij.enable = true;
  darrint.ai.enable = true;
}
