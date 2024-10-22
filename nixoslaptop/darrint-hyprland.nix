{ pkgs, ... }@allargs:
{
  home.packages = [
    pkgs.hyprnome
    pkgs.hyprlandPlugins.hyprexpo
    pkgs.brightnessctl
    pkgs.dunst
    pkgs.waypaper
    pkgs.variety
    pkgs.rofi-wayland
    pkgs.grimblast
    pkgs.lxqt.lxqt-policykit
  ] ++ [
    pkgs.hypridle
    pkgs.wlogout
    pkgs.waybar
    pkgs.hyprlock
  ];

}

