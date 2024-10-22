{
  config,
  pkgs,
  lib,
  ...
}:
let
  iosevka-nfm = (pkgs.nerdfonts.override { fonts = ["Iosevka"]; });
  monoid-nfm = (pkgs.nerdfonts.override { fonts = ["Monoid"]; });
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  stylix = {
    enable = true;
    image = ../wallpaper/kalen-emsley-Bkci_8qcdvQ-unsplash.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/evenok-dark.yaml";
    fonts = {
      sansSerif = {
        name = "Inter";
        package = pkgs.inter;
      };
      monospace = {
        name = "Iosevka";
        package = iosevka-nfm;
      };
    };
  };
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      inconsolata-nerdfont
      terminus-nerdfont
      iosevka-nfm
      monoid-nfm
      inter
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    trusted-users = [ "root" "darrint" ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  networking.extraHosts = '''';

  # Set your time zone.
  time.timeZone = "America/Indiana/Indianapolis";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

  # Enable sound with pipewire.
  # deprecated:
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.flatpak.enable = true;
  services.fwupd.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.darrint = {
    isNormalUser = true;
    description = "Darrin Thompson";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr1N+n9997wxRQ+Ss3oj1Ztg726vSVMelxdoSDkM/kqUL6ylELfyiF6ZYeZbTftd4TzJRW8zloltpVE1GnoaNnm/0clLCtJK6gQRNBKx+JBZaF26WpH0yo+Vt2puvajAchrfpzZl/HqZL5RscY+Gs8hS+u7IfbWQ8o/JhyUsY2rgsPSw58LQS8br22EZAcBCOMLXffer7l5489/g83sTKdgyvW2kWq+E97uMswJ2ytAhNbCdYDIGuceHymIVkNAmJ6FS3ykCiOthYGCNIWReR4VQRMix0wqxxxfXrtSXyYio3lhUTEnA2jWmJiVOfy94vRfkMFopuDOp2nOIxbKJhl"
    ];
    packages = with pkgs; [
      firefox
      logseq
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  xdg.portal = {
    wlr.enable = lib.mkForce true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    cachix
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "darrint" ];
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;

  };
  programs.hyprlock.enable = true;
  # services.hypridle.enable = true;

  programs.wayfire.enable = true;

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
    flake = "/home/darrint/nixos";
  };

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    # port = 5432;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust

      #type database DBuser origin-address auth-method
      # ipv4
      host  all      all     127.0.0.1/32   scram-sha-256
      # ipv6
      host all       all     ::1/128        scram-sha-256
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE doubloon_dev WITH LOGIN PASSWORD 'password' CREATEDB;
      CREATE ROLE doubloon_test WITH LOGIN PASSWORD 'password' CREATEDB;
      GRANT ALL PRIVILEGES ON DATABASE doubloon_dev TO doubloon_dev;
      GRANT ALL PRIVILEGES ON DATABASE doubloon_test TO doubloon_test;
      \c template1
      CREATE EXTENSION IF NOT EXISTS citext;
      CREATE DATABASE doubloon_dev WITH OWNER = doubloon_dev;
      CREATE DATABASE doubloon_test WITH OWNER = doubloon_test;
    '';
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8000
    4000
    8080
    8081
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
