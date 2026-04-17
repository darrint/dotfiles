{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.limine = {
    enable = true;
    enableEditor = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "nixoslaptop";
  networking.wireguard.enable = true;

  darrint.desktop.enable = true;
  darrint.pipewire.enable = true;
  darrint.pipewire.jack = true;
  darrint.podman.enable = true;
  darrint.steam.enable = true;
  darrint.onepassword.enable = true;
  darrint.gaming.enable = true;

  darrint.user.extraGroups = [
    "networkmanager"
    "dialout"
  ];
  darrint.user.authorizedKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr1N+n9997wxRQ+Ss3oj1Ztg726vSVMelxdoSDkM/kqUL6ylELfyiF6ZYeZbTftd4TzJRW8zloltpVE1GnoaNnm/0clLCtJK6gQRNBKx+JBZaF26WpH0yo+Vt2puvajAchrfpzZl/HqZL5RscY+Gs8hS+u7IfbWQ8o/JhyUsY2rgsPSw58LQS8br22EZAcBCOMLXffer7l5489/g83sTKdgyvW2kWq+E97uMswJ2ytAhNbCdYDIGuceHymIVkNAmJ6FS3ykCiOthYGCNIWReR4VQRMix0wqxxxfXrtSXyYio3lhUTEnA2jWmJiVOfy94vRfkMFopuDOp2nOIxbKJhl"
  ];

  # x-plane-11 is a local flake package, so it stays here
  environment.systemPackages = [
    inputs.self.packages.${pkgs.system}.x-plane-11
  ];

  networking.firewall.allowedTCPPorts = [
    8000
    4000
    8080
    8081
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
