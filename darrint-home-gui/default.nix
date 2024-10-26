
{ pkgs, lib, localPackages, ... }:

{
  imports = [
    ../darrint-home
    ./hyprland.nix
  ];

  fonts = {
    fontconfig = {
      defaultFonts = {
        monospace = ["Iosevka NFM Light"];
      };
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.libsForQt5.qt5.qtwayland
    pkgs.kdePackages.qtwayland
    pkgs._1password-gui
    pkgs.fuzzel
    pkgs.vscode
    pkgs.zoom-us
    pkgs.slack
    pkgs.gimp
    pkgs.easyeffects
    pkgs.reaper
    pkgs.musescore
    pkgs.wl-clipboard
    pkgs.foot
    pkgs.libnotify
    pkgs.gnomeExtensions.blur-my-shell
    pkgs.gnomeExtensions.tiling-shell
    pkgs.kitty
  ];

  programs.firefox.enable = true;
  programs.brave.enable = true;
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-gradient-source
    ];
  };
  programs.waybar = {
    enable = true;
  };
}
