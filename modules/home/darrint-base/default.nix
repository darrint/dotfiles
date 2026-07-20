{
  pkgs,
  inputs,
  ...
}: let
  ntpkgs = inputs.numtide-ai-tools.packages.${pkgs.system};
in {
  home.stateVersion = "24.11";
  home.packages = [
    pkgs.killall
    pkgs.nixfmt-rfc-style
    pkgs.devenv
    pkgs.lolcat
    pkgs.figlet
    pkgs.dig
    pkgs.wget
    pkgs.strace
    ntpkgs.opencode
    pkgs.python3
    pkgs.jq
    pkgs.curl
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
    matchBlocks."*" = {
      addKeysToAgent = "yes";
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      controlMaster = "auto";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "10m";
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
}
