{ lib, config, ... }:
let
  cfg = config.darrint.pipewire;
in
{
  options.darrint.pipewire = {
    enable = lib.mkEnableOption "Enable pipewire audio";
    jack = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable JACK support in pipewire.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = cfg.jack;
    };
  };
}
