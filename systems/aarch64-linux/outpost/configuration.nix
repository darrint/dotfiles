{...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "outpost";

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  services.openssh.enable = true;

  darrint.user.authorizedKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr1N+n9997wxRQ+Ss3oj1Ztg726vSVMelxdoSDkM/kqUL6ylELfyiF6ZYeZbTftd4TzJRW8zloltpVE1GnoaNnm/0clLCtJK6gQRNBKx+JBZaF26WpH0yo+Vt2puvajAchrfpzZl/HqZL5RscY+Gs8hS+u7IfbWQ8o/JhyUsY2rgsPSw58LQS8br22EZAcBCOMLXffer7l5489/g83sTKdgyvW2kWq+E97uMswJ2ytAhNbCdYDIGuceHymIVkNAmJ6FS3ykCiOthYGCNIWReR4VQRMix0wqxxxfXrtSXyYio3lhUTEnA2jWmJiVOfy94vRfkMFopuDOp2nOIxbKJhl"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqfQpi/XLuVR1HNaEt0U3VcylIBYWLg7CGsYA5aKDHyY/MUB+dWAyk6VvzA6GTnH1yn6SOch1fS55bWAKFYhEQ3tgCMHrxLFRNaKWocJnDeuhI2ls2LQGAIe7oDTR4lq0A2EuL82f8HOVMVEYovi4plTJIgQSb0sDlkTIvytbXQ6VJ7aEOEIBePAomyB/5lp0J3qlfeUJ9WnKJS2CbN192hiAPyKDe2z2VBCDLgYQ3hgo9bPnK6g4PDFvJHxVdIsPY2HUkFInPBBULcZwS7CW/ndFCG0bFdP+ngptF15MX8BWUwL/BmT0SdQXj3SKtpnS252ee6YcLQgeANNMoFc05 darrint@darrint-Precision-7520"
  ];

  system.stateVersion = "25.11";
}
