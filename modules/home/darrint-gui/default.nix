{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.darrint.gui;
in {
  options.darrint.gui = {
    enable = lib.mkEnableOption "Enable darrint GUI stuff";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontconfig = {
        defaultFonts = {
          monospace = ["Iosevka NFM Light"];
        };
      };
    };

    home.packages = [
      pkgs.libsForQt5.qt5.qtwayland
      pkgs.kdePackages.qtwayland
      pkgs._1password-gui
      pkgs.vscode
      pkgs.zoom-us
      pkgs.slack
      pkgs.gimp
      pkgs.easyeffects
      pkgs.reaper
      pkgs.musescore
      pkgs.wl-clipboard
      pkgs.libnotify
      pkgs.gnomeExtensions.blur-my-shell
      pkgs.gnomeExtensions.tiling-shell
      pkgs.kitty
      pkgs.obsidian
    ];

    programs.firefox.enable = true;
    programs.brave.enable = true;
  };
}
