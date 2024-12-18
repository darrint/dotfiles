{ ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        height = 30;
        margin-top = 6;
        margin-left = 10;
        margin-bottom = 0;
        marging-right = 10;
        spacing = 5;
        modules-left = [
          "wlr/workspaces"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "cpu"
          "memory"
          "network"
          "battery"
          "tray"
          "custom/exit"
        ];
        "wlr/workspaces" = {
          "format" = "{icon}";
          "on-click" = "activate";
          "format-icons" = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "urgent" = "U";
            "active" = "A";
            "default" = "D";
          };
        };
        "custom/exit" = {
          "format" = "   ";
          "on-click" = "wlogout -b 4";
          "tooltip" = false;
          "tooltip-format" = "Powermenu";
        };
        "clock" = {
          "format" = "<span color='#bf616a'>  </span>{:%a %b %d}";
          "format-alt" = "<span color='#bf616a'>  </span>{:%I:%M %p}";
          "tooltip-format" = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
        };
        "cpu" = {
          "interval" = 10;
          "format" = "  {}%";
          "max-length" = 10;
          "on-click" = "";
        };
        "memory" = {
          "interval" = 30;
          "format" = "  {}%";
          "format-alt" = "  {used:0.1f}G";
          "max-length" = 10;
        };

        "network" = {
          "format-wifi" = "  {signalStrength}%";
          "format-ethernet" = "󰈁  wired";
          "format-disconnected" = "󰖪  ";
          "on-click" = "bash ~/.config/waybar/scripts/rofi-wifi-menu.sh";
        };

        "battery" = {
          "bat" = "BAT0";
          "adapter" = "ADP0";
          "interval" = 60;
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "max-length" = 20;
          "format" = "{icon}  {capacity}%";
          "format-warning" = "{icon}  !{capacity}%";
          "format-critical" = "{icon}  !!!{capacity}%";
          "format-charging" = "  {capacity}%";
          "format-plugged" = "   {capacity}%";
          "format-alt" = "{icon}  {time}";
          "format-full" = "  {capacity}%";
          "format-icons" = [
            " "
            " "
            " "
            " "
            " "
          ];
        };
        "tray" = {
          "spacing" = 10;
        };

      };
    };
  };
}

# {
#   mainBar = {
#     # Workspaces
#     "hyprland/workspaces" = {
#         "on-click" = "activate";
#         "active-only" = false;
#         "all-outputs" = true;
#         "format" = "{}";
#         "format-icons"= {
#                         "urgent" = "";
#                         "active" = "";
#                         "default" = "";
#         };
#         "persistent-workspaces"= {
#              "*" = 5;
#         };
#     };
#
#     # Hyprland Window
#     "hyprland/window"= {
#         "rewrite" = {
#             "(.*) - Brave" = "$1";
#             "(.*) - Chromium" = "$1";
#             "(.*) - Brave Search" = "$1";
#             "(.*) - Outlook" = "$1";
#             "(.*) Microsoft Teams" = "$1";
#         };
#         "separate-outputs" = true;
#     };
#
#     # Rofi Application Launcher
#     "custom/appmenu" = {
#         "format" = "Apps";
#         "tooltip-format" = "Left: Open the application launcher";
#         "on-click" = "fuzzel";
#         "tooltip" = false;
#     };
#
#     # Power Menu
#     "custom/exit" = {
#         "format" = "   ";
#         "tooltip-format" = "Powermenu";
#         "on-click" = "wlogout -b 4";
#         "tooltip" = false;
#     };
#
#     # Keyboard State
#     "keyboard-state" = {
#         "numlock" = true;
#         "capslock" = true;
#         "format" = "{name} {icon}";
#         "format-icons" = {
#             "locked" = "";
#             "unlocked" = "";
#         };
#     };
#
#     # System tray
#     "tray" = {
#         # "icon-size" = 21;
#         "spacing" = 10;
#     };
#
#     # Clock
#     "clock" = {
#       "timezone" = "America/New_York";
#       "format" = "{:%I:%M %p - %A, %B %d, %Y}";
#       "tooltip-format" = "<tt><small>{calendar}</small></tt>";
#       # "format-alt" = "<tt><small>{calendar}</small></tt>";
#       "calendar" = {
#         "mode" = "month";
#         "mode-mon-col" = 3;
#         "weeks-pos" = "right";
#         "on-scroll" = 1;
#         "format"= {
#           "months"=     "<span color='#ffead3'><b>{}</b></span>";
#           "days"=       "<span color='#ecc6d9'>{}</span>";
#           "weeks"=      "<span color='#99ffdd'>W{}</span>";
#           "weekdays"=   "<span color='#ffcc66'><b>{}</b></span>";
#           "today"=      "<span color='#ff6699'><b><u>{}</u></b></span>";
#         };
#       };
#     };
#
#     # System
#     "custom/system" = {
#         "format" = "";
#         "tooltip" = false;
#     };
#
#     # CPU
#     "cpu" = {
#         "format" = "/ C {usage}% ";
#         "on-click" = "kitty -e htop";
#     };
#
#     # Memory
#     "memory" = {
#         "format" = "/ M {}% ";
#         "on-click" = "kitty -e htop";
#     };
#
#     # Harddisc space used
#     "disk" = {
#         "interval" = 30;
#         "format" = "D {percentage_used}% ";
#         "path" = "/";
#         "on-click" = "kitty -e htop";
#     };
#
#     "hyprland/language" = {
#         "format" = "/ K {short}";
#     };
#
#     # Group Hardware
#     "group/hardware" = {
#         "orientation" = "inherit";
#         "drawer" = {
#             "transition-duration" = 300;
#             "children-class" = "not-memory";
#             "transition-left-to-right" = false;
#         };
#         # "modules" = [
#         #     "custom/system"
#         #     "disk"
#         #     "cpu"
#         #     "memory"
#         #     "hyprland/language"
#         # ];
#     };
#
#    # Network
#     "network" = {
#         "format" = "{ifname}";
#         "format-wifi" = "   {signalStrength}%";
#         "format-ethernet" = "  {ipaddr}";
#         "format-disconnected" = "Not connected"; #An empty format will hide the module.
#         "tooltip-format" = " {ifname} via {gwaddri}";
#         "tooltip-format-wifi" = "   {essid} ({signalStrength}%)";
#         "tooltip-format-ethernet" = "  {ifname} ({ipaddr}/{cidr})";
#         "tooltip-format-disconnected" = "Disconnected";
#         "max-length" = 50;
#         "on-click" = "alacritty -e nmtui";
#     };
#
#     # Battery
#     "battery" = {
#         "states" = {
#             # "good" = 95;
#             "warning" = 30;
#             "critical" = 15;
#         };
#         "format" = "{icon}   {capacity}%";
#         "format-charging" = "  {capacity}%";
#         "format-plugged" = "  {capacity}%";
#         "format-alt" = "{icon}  {time}";
#         # "format-good" = ""; // An empty format will hide the module
#         "format-full" = "  100%";
#         "format-icons" = [ " " " " " " " " " "];
#     };
#
#     # Pulseaudio
#     "pulseaudio" = {
#         # "scroll-step" = 1, // %, can be a float
#         "format" = "{icon}  {volume}%";
#         "format-bluetooth" = "{volume}% {icon} {format_source}";
#         "format-bluetooth-muted" = " {icon} {format_source}";
#         "format-muted" = " {format_source}";
#         "format-source" = "{volume}% ";
#         "format-source-muted" = "";
#         "format-icons" = {
#             "headphone" = "";
#             "hands-free" = "";
#             "headset" = "";
#             "phone" = "";
#             "portable" = "";
#             "car" = "";
#             "default" = ["" " " " "];
#         };
#         "on-click" = "pavucontrol";
#     };
#
#     # Bluetooth
#     "bluetooth" = {
#         "format-disabled" = "";
#         "format-off" = "";
#         "interval" = 30;
#         "on-click" = "blueman-manager";
#         "format-no-controller" = "";
#     };
#
#     # Other
#     "user" = {
#         "format" = "{user}";
#         "interval" = 60;
#         "icon" = false;
#     };
#
#     # Idle Inhibator
#     "idle_inhibitor" = {
#         "format" = "{icon}";
#         "tooltip" = true;
#         "format-icons" ={
#             "activated" = "";
#             "deactivated" = "";
#         };
#         "on-click-right" = "hyprlock";
#     };
#     modules-left = [
#         "custom/appmenu"
#         "group/quicklinks"
#         "hyprland/window"
#     ];
#     modules-center = [
#         "clock"
#         # "hyprland/workspaces"
#     ];
#     modules-right = [
#         "mpd"
#         "pulseaudio"
#         "network"
#         "cpu"
#         "memory"
#         "keyboard-state"
#         "battery"
#         "tray"
#         "custom/exit"
#     ];
#   };
# }
