{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.inconsolata
      nerd-fonts.iosevka
      nerd-fonts.monoid
      inter
    ];
  };

  nix.settings.trusted-users = [
    "root"
    "darrint"
  ];

  # Bootloader.
  boot.loader.limine = {
    enable = true;
    enableEditor = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
  };
  boot.kernelParams = [ "quiet" ];

  # v4l2loopback for OBS, etc.
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="Loopback Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;

  networking.hostName = "nixoslaptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;
  networking.extraHosts = "";

  hardware.keyboard.qmk.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.displayManager.sddm.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  darrint.pipewire.enable = true;
  darrint.pipewire.jack = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.flatpak.enable = true;
  services.fwupd.enable = true;

  darrint.user.extraGroups = [
    "networkmanager"
    "dialout"
  ];
  darrint.user.authorizedKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr1N+n9997wxRQ+Ss3oj1Ztg726vSVMelxdoSDkM/kqUL6ylELfyiF6ZYeZbTftd4TzJRW8zloltpVE1GnoaNnm/0clLCtJK6gQRNBKx+JBZaF26WpH0yo+Vt2puvajAchrfpzZl/HqZL5RscY+Gs8hS+u7IfbWQ8o/JhyUsY2rgsPSw58LQS8br22EZAcBCOMLXffer7l5489/g83sTKdgyvW2kWq+E97uMswJ2ytAhNbCdYDIGuceHymIVkNAmJ6FS3ykCiOthYGCNIWReR4VQRMix0wqxxxfXrtSXyYio3lhUTEnA2jWmJiVOfy94vRfkMFopuDOp2nOIxbKJhl"
  ];

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "darrint";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # bluetooth passthrough
  services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/70-dolphin-bt.rules" ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="8087", ATTRS{idProduct}=="0a2b", TAG+="uaccess"
    '')
  ];

  # Allow screen sharing in some apps.
  xdg.portal = {
    wlr.enable = lib.mkForce true;
  };

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      cachix
      dive
      podman-tui
      docker-compose
      podman-compose

      waypipe

      dolphin-emu
      xenia-canary
      xemu
      (retroarch.withCores (
        cores: with cores; [
          pcsx2
          beetle-psx-hw

          snes9x
          mesen
        ]
      ))
    ]
    ++ [
      inputs.self.packages.${pkgs.system}.x-plane-11
    ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "darrint" ];
  };

  programs.steam = {
    enable = true;
    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;
    # Open ports in the firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
    # Open ports in the firewall for Steam Local Network Game Transfers
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = false;
    # flake = "/home/darrint/dotfiles";
  };
  programs.localsend.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8000
    4000
    8080
    8081
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
  /*
    snowfallorg.users.darrint = {
      create = true;
      admin = false;

      home = {
        enable = true;

        config = {
          description = "Darrin Thompson";
          extraGroups = [
            "networkmanager"
            "wheel"
            "dialout"
          ];
          openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr1N+n9997wxRQ+Ss3oj1Ztg726vSVMelxdoSDkM/kqUL6ylELfyiF6ZYeZbTftd4TzJRW8zloltpVE1GnoaNnm/0clLCtJK6gQRNBKx+JBZaF26WpH0yo+Vt2puvajAchrfpzZl/HqZL5RscY+Gs8hS+u7IfbWQ8o/JhyUsY2rgsPSw58LQS8br22EZAcBCOMLXffer7l5489/g83sTKdgyvW2kWq+E97uMswJ2ytAhNbCdYDIGuceHymIVkNAmJ6FS3ykCiOthYGCNIWReR4VQRMix0wqxxxfXrtSXyYio3lhUTEnA2jWmJiVOfy94vRfkMFopuDOp2nOIxbKJhl"
          ];
        };
      };
    };
  */
}
