{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.darrint.desktop;
in
{
  options.darrint.desktop = {
    enable = lib.mkEnableOption "Enable darrint GNOME desktop";
    autoLoginUser = lib.mkOption {
      type = lib.types.str;
      default = "darrint";
      description = "User to auto-login on the desktop.";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        nerd-fonts.inconsolata
        nerd-fonts.iosevka
        nerd-fonts.monoid
        inter
      ];
    };

    security.polkit.enable = true;

    boot.plymouth.enable = true;
    boot.kernelParams = [ "quiet" ];

    # v4l2loopback for OBS, etc.
    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="Loopback Cam" exclusive_caps=1
    '';

    hardware.keyboard.qmk.enable = true;
    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
    };

    networking.networkmanager.enable = true;

    services.xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.flatpak.enable = true;
    services.fwupd.enable = true;

    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = cfg.autoLoginUser;

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    # bluetooth passthrough for Dolphin emulator
    services.udev.packages = [
      (pkgs.writeTextDir "etc/udev/rules.d/70-dolphin-bt.rules" ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="8087", ATTRS{idProduct}=="0a2b", TAG+="uaccess"
      '')
    ];

    programs.localsend.enable = true;

    environment.systemPackages = with pkgs; [
      waypipe
    ];
  };
}
