{pkgs, ...}: {
  home.stateVersion = "24.11";
  home.packages = [
    pkgs.killall
    pkgs.direnv
    pkgs.nixfmt-rfc-style
    pkgs.frotz
    pkgs.zk
    pkgs.nb
    pkgs.fzf
    pkgs.ripgrep
    pkgs.fd
    pkgs.devenv
    pkgs.htop
    pkgs.lolcat
    pkgs.figlet
    pkgs.nh
    pkgs.dig
  ];

  # Let Home Manager install and manage itself.
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.nushell.enable = true;
  programs.git = {
    enable = true;
    userName = "darrint";
    userEmail = "darrint@fastmail.com";
  };
  programs.direnv.enable = true;
  programs.zellij.enable = true;

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      format = "";
    };
  };
}
