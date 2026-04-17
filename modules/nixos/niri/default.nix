{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.darrint.niri;
in
{
  options.darrint.niri.enable = lib.mkEnableOption "niri wayland compositor with noctalia shell";

  config = lib.mkIf cfg.enable {
    services.displayManager.sessionPackages = [ pkgs.niri ];
    services.displayManager.defaultSession = "niri";

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    xdg.portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      configPackages = [ pkgs.niri ];
    };

    environment.systemPackages = [
      pkgs.xwayland-satellite
      inputs.noctalia.packages.${pkgs.system}.default
    ];
  };
}
