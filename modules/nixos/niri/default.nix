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
  imports = [ inputs.dms.nixosModules.dank-material-shell ];

  options.darrint.niri.enable = lib.mkEnableOption "niri wayland compositor with DMS shell";

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      # dgop (system monitor) not in nixpkgs stable — disable and stub the package
      enableSystemMonitoring = false;
      dgop.package = pkgs.writeShellScriptBin "dgop" "echo 'dgop stub: system monitoring disabled'";
    };

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
      # noctalia kept as an optional fallback; run manually with: noctalia-shell
      inputs.noctalia.packages.${pkgs.system}.default
    ];
  };
}
