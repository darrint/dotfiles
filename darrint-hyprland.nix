{ pkgs, config, ... }@allargs:
#let
#  hypr-config = pkgs.callPackage (import ./hypr) allargs;
#in
{
  home.packages = [
    pkgs.hyprnome
    pkgs.brightnessctl
    pkgs.dunst
    pkgs.swww
    pkgs.waypaper
    pkgs.variety
  ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";       # avoid starting multiple hyprlock instances.
        before_sleep_cmd = "loginctl lock-session";    # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on";  # to avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = "150";                                # 2.5min.
          on-timeout = "brightnessctl -s set 10";         # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "brightnessctl -r";                 # monitor backlight restore.
        }

        {
          timeout = "300";                                 # 5min
          on-timeout = "loginctl lock-session";            # lock screen when timeout has passed
        }

        {
          timeout = "330";                                 # 5.5min
          on-timeout = "hyprctl dispatch dpms off";        # screen off when timeout has passed
          on-resume = "hyprctl dispatch dpms on";          # screen on when activity is detected after timeout has fired.
        }

        {
          timeout = "1800";                                # 30min
          on-timeout = "systemctl suspend";                # suspend pc
        }
      ];
    };
  };

  programs.wlogout = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = import ./darrint-waybar.nix;
  };

  programs.hyprlock = {
    enable = true;
    settings = import ./darrint-hyprlock.nix;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [ pkgs.hyprlandPlugins.hyprexpo ];
    settings = {
      "$mod" = "SUPER";
      general = {
        layout = "dwindle";
        resize_on_border = "true";
      };
      misc = {
        disable_hyprland_logo = "true";
      };
      exec-once = [
        "waybar"
        "dunst"
        "waypaper --restore"
      ];
      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];

      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      gestures = {
        workspace_swipe = true;
      };
      monitor = [
        "eDP-1,preferred,auto,1"
        "desc:BNQ NenQ GW2765,preferred,auto-right,1"
      ];
      bind = [
        # My original
        # "$mod, F, togglefloating"
        # "$mod + SHIFT, F, fullscreen"
        # "$mod, T, exec, kitty"
        "$mod + CTRL, left, exec, hyprnome --previous"
        "$mod + CTRL, right, exec, hyprnome"
        "$mod + CTRL + SHIFT, left, exec, hyprnome --previous --move"
        "$mod + CTRL + SHIFT, right, exec, hyprnome --move"
        "$mod, tab, hyprexpo:expo, toggle"
        "$mod, L, exec, hyprlock"
        "$mod, SUPER_L, exec, fuzzel"

        # ML4W
        "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive # Close current window"
        "$mod, M, exit # Exit Hyprland"
        # "$momod E, exec, ~/.config/ml4w/settings/filemanager.sh # Opens the filemanager"
        "$mod, T, togglefloating # Toggle between tiling and floating window"
        "$mod, F, fullscreen # Open the window in fullscreen"
        # "$mod CTRL, RETURN, exec, rofi -show drun # Open rofi"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"
        "$mod, B, exec, ~/.config/ml4w/settings/browser.sh # Opens the browser"
        # "$mod SHIFT, B, exec, ~/.config/ml4w/scripts/reload-waybar.sh # Reload Waybar"
        # "$mod SHIFT, W, exec, ~/.config/ml4w/scripts/reload-hyprpaper.sh # Reload hyprpaper after a changing the wallpaper"

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l # Move focus left"
        "$mod, right, movefocus, r # Move focus right"
        "$mod, up, movefocus, u # Move focus up"
        "$mod, down, movefocus, d # Move focus down"


        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1 #  Move window to workspace 1"
        "$mod SHIFT, 2, movetoworkspace, 2 #  Move window to workspace 2"
        "$mod SHIFT, 3, movetoworkspace, 3 #  Move window to workspace 3"
        "$mod SHIFT, 4, movetoworkspace, 4 #  Move window to workspace 4"
        "$mod SHIFT, 5, movetoworkspace, 5 #  Move window to workspace 5"
        "$mod SHIFT, 6, movetoworkspace, 6 #  Move window to workspace 6"
        "$mod SHIFT, 7, movetoworkspace, 7 #  Move window to workspace 7"
        "$mod SHIFT, 8, movetoworkspace, 8 #  Move window to workspace 8"
        "$mod SHIFT, 9, movetoworkspace, 9 #  Move window to workspace 9"
        "$mod SHIFT, 0, movetoworkspace, 10 #  Move window to workspace 10"

        # Scroll through existing workspaces with mod + scroll
        # "$mod, mouse_down, workspace, e+1 # Scroll workspaces "
        # "$mod, mouse_up, workspace, e-1 # Scroll workspaces"

        ", $mod, exec, fuzzel"


      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

}
