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
      pkgs.zoom-us
      pkgs.slack
      pkgs.gimp
      pkgs.easyeffects
      pkgs.reaper
      pkgs.musescore
      pkgs.wl-clipboard
      pkgs.libnotify
      pkgs.pinta
      pkgs.gnomeExtensions.blur-my-shell
      pkgs.gnomeExtensions.tiling-shell
      pkgs.gnome-tweaks
      pkgs.obsidian
    ];

    programs.firefox.enable = true;
    programs.brave.enable = true;
    programs.kitty = {
      enable = true;
      font = {
        name = "Iosevka";
        size = 10;
      };
      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };
    };
    programs.wezterm = {
      enable = true;
      # font = {
      #   name = "Iosevka";
      #   size = 10;
      # };
      enableBashIntegration = true;
      enableZshIntegration = true;
      # enableFishIntegration = true;
    };
    programs.vscode.enable = true;
  };
}
