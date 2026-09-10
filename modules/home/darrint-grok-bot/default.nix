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

    # sand:// login redirects → grok-bot after first install/login
    xdg.mimeApps = {
      enable = true;
      defaultApplications."x-scheme-handler/sand" = [ "grok-bot.desktop" ];
    };
  };
}
