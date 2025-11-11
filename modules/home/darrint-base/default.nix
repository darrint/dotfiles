{pkgs, ...}: {
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
  programs.eza.enable = true;

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
    };
  };
  programs.zoxide.enable = true;
  programs.fastfetch.enable = true;
  programs.lazygit.enable = true;
  programs.nh.enable = true;
  programs.htop.enable = true;
  programs.btop.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.fzf.enable = true;
}
