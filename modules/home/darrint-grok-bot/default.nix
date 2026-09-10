{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.darrint.grok-bot;
in
{
  options.darrint.grok-bot = {
    enable = lib.mkEnableOption "xAI Grok Bot desktop agent";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      inputs.grok-bot.packages.${pkgs.system}.default
    ];

    # Electron/Chromium Wayland (niri); grok-bot wrapper honors this
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    # Do not enable xdg.mimeApps here — it owns mimeapps.list and clobbers
    # existing unmanaged defaults (browsers, etc.). After install, either:
    #   xdg-mime default grok-bot.desktop x-scheme-handler/sand
    # or let the app register sand:// on first launch.
  };
}
