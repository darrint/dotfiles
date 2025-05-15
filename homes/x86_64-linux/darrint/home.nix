{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./nvf.nix
  ];
  programs.zellij.enable = true;
  programs.git = {
    enable = true;
    userName = "Darrin Thompson";
    userEmail = "darrint@fastmail.com";
  };
  programs.nh.enable = true;
}
