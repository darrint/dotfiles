{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.darrint.gaming;
in
{
  options.darrint.gaming = {
    enable = lib.mkEnableOption "Enable darrint gaming packages (emulators)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
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
    ];
  };
}
