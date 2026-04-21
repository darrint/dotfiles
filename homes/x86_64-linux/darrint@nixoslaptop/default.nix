{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  niriSplash = pkgs.writeShellScript "niri-splash" ''
    # Show a solid background immediately while DMS loads.
    ${pkgs.swaybg}/bin/swaybg -c '#0e0e43' &
    SWAYBG_PID=$!

    # Poll until DMS IPC responds (max ~30 s, 300 ms intervals).
    # We probe with a benign call; dms exits non-zero if not ready.
    for i in $(seq 1 100); do
      if dms ipc spotlight toggle >/dev/null 2>&1; then
        # DMS is up — close spotlight again immediately
        dms ipc spotlight toggle >/dev/null 2>&1 || true
        break
      fi
      sleep 0.3
    done

    kill "$SWAYBG_PID" 2>/dev/null
  '';

  wallpaperRefresh = pkgs.writeShellScript "wallpaper-refresh" ''
    set -euo pipefail
    DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$DIR"

    FILE="$DIR/wallpaper-$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S).jpg"

    # Fetch today's Bing photo of the day (always a high-quality landscape/nature image)
    BING_API="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US"
    IMG_PATH=$(${pkgs.curl}/bin/curl -sL "$BING_API" \
      | ${pkgs.gnugrep}/bin/grep -o '"url":"[^"]*"' \
      | ${pkgs.gnused}/bin/sed 's/"url":"//;s/"//')
    ${pkgs.curl}/bin/curl -sL "https://www.bing.com$IMG_PATH" -o "$FILE"

    # Apply wallpaper if DMS is running
    if dms ipc wallpaper set "$FILE" 2>/dev/null; then
      echo "Wallpaper set: $FILE"
    else
      echo "DMS not running; wallpaper saved for next session: $FILE"
    fi

    # Keep only the 30 most recent
    ls -t "$DIR"/*.jpg 2>/dev/null | ${pkgs.coreutils}/bin/tail -n +31 | xargs -r rm --
  '';
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  darrint.neovim.enable = true;
  darrint.gui.enable = true;
  darrint.frc.enable = true;

  programs.dank-material-shell = {
    enable = true;
    # DMS spawned via spawn-at-startup in hm.kdl; not via systemd
    systemd.enable = false;
    # Calendar events not needed
    enableCalendarEvents = false;
    # dgop (system monitor) not in nixpkgs stable — disable and stub the package
    enableSystemMonitoring = false;
    dgop.package = pkgs.writeShellScriptBin "dgop" "echo 'dgop stub: system monitoring disabled'";
  };

  home.packages = with pkgs; [
    brightnessctl # required by DMS for brightness control
    cliphist # clipboard history (wl-clipboard is in darrint-gui)
    wlsunset # night light
  ];

  # Use an activation script to pre-create stub DMS config fragments if absent.
  # Niri parses config.kdl (which includes these) before DMS has run on first boot.
  # We only create them if missing so DMS can freely overwrite with real content.
  home.activation.dmsStubbedIncludes = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dms_dir="$HOME/.config/niri/dms"
    mkdir -p "$dms_dir"
    for f in alttab binds colors cursor layout outputs windowrules wpblur; do
      if [ ! -f "$dms_dir/$f.kdl" ]; then
        echo "// placeholder — DMS will overwrite this at runtime" > "$dms_dir/$f.kdl"
      fi
    done
  '';

  home.activation.wallpaperDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/Pictures/Wallpapers"
  '';

  # Fetch a new landscape wallpaper every 3 hours and on session start
  systemd.user.services.wallpaper-refresh = {
    Unit = {
      Description = "Download a fresh landscape wallpaper from Unsplash";
      After = [ "graphical-session.target" ];
      Requires = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${wallpaperRefresh}";
    };
  };

  systemd.user.timers.wallpaper-refresh = {
    Unit.Description = "Refresh wallpaper every 3 hours";
    Timer = {
      OnActiveSec = "1min"; # small delay after login so DMS is ready
      OnUnitActiveSec = "3h";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  home.file.".config/niri/config.kdl".text = ''
    include "hm.kdl"
    include "dms/alttab.kdl"
    include "dms/binds.kdl"
    include "dms/colors.kdl"
    include "dms/cursor.kdl"
    include "dms/layout.kdl"
    include "dms/outputs.kdl"
    include "dms/windowrules.kdl"
    include "dms/wpblur.kdl"
  '';

  home.file.".config/niri/hm.kdl".text = ''
    hotkey-overlay {
      skip-at-startup
    }
    window-rule {
      geometry-corner-radius 20
      clip-to-geometry true
    }

    debug {
      honor-xdg-activation-with-invalid-serial
    }

    // Stationary wallpaper visible at all times including niri overview
    layer-rule {
      match namespace="^dms-wallpaper*"
      place-within-backdrop true
    }

    layout {
      background-color "transparent"
    }

    spawn-at-startup "${niriSplash}"
    spawn-at-startup "dms" "run"

    input {
      touchpad {
        tap
        natural-scroll
      }
      mouse {
        natural-scroll
      }
    }

    binds {
      // Terminal
      Mod+Return { spawn "kitty"; }

      // Hotkey overlay
      Mod+Shift+Slash { show-hotkey-overlay; }

      // Close window
      Mod+Q repeat=false { close-window; }

      // Focus navigation
      Mod+Ctrl+Left  { focus-column-left; }
      Mod+Ctrl+Down  { focus-window-down; }
      Mod+Ctrl+Up    { focus-window-up; }
      Mod+Ctrl+Right { focus-column-right; }
      Mod+Ctrl+H     { focus-column-left; }
      Mod+Ctrl+J     { focus-window-down; }
      Mod+Ctrl+K     { focus-window-up; }
      Mod+Ctrl+L     { focus-column-right; }

      // Move windows/columns (Mod+Shift)
      Mod+Ctrl+Shift+Left  { move-column-left; }
      Mod+Ctrl+Shift+Down  { move-window-down; }
      Mod+Ctrl+Shift+Up    { move-window-up; }
      Mod+Ctrl+Shift+Right { move-column-right; }
      Mod+Ctrl+Shift+H     { move-column-left; }
      Mod+Ctrl+Shift+J     { move-window-down; }
      Mod+Ctrl+Shift+K     { move-window-up; }
      Mod+Ctrl+Shift+L     { move-column-right; }

      // First / last column
      Mod+Home       { focus-column-first; }
      Mod+End        { focus-column-last; }
      Mod+Shift+Home { move-column-to-first; }
      Mod+Shift+End  { move-column-to-last; }

      // Workspace navigation
      Mod+U              { focus-workspace-down; }
      Mod+I              { focus-workspace-up; }
      Mod+Page_Down      { focus-workspace-down; }
      Mod+Page_Up        { focus-workspace-up; }
      Mod+Ctrl+U         { move-column-to-workspace-down; }
      Mod+Ctrl+I         { move-column-to-workspace-up; }
      Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
      Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }

      // Workspace by index
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }

      // Overview
      Mod+O repeat=false { toggle-overview; }

      // Window layout
      Mod+F         { maximize-column; }
      Mod+Shift+F   { fullscreen-window; }
      Mod+Ctrl+F    { expand-column-to-available-width; }
      Mod+R         { switch-preset-column-width; }
      Mod+Shift+R   { switch-preset-window-height; }
      Mod+Ctrl+R    { reset-window-height; }
      Mod+C         { center-column; }
      Mod+Ctrl+C    { center-visible-columns; }
      Mod+Ctrl+V    { switch-focus-between-floating-and-tiling; }
      Mod+W         { toggle-column-tabbed-display; }

      // Consume / expel
      Mod+BracketLeft  { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }

      // Resize
      Mod+Minus       { set-column-width "-10%"; }
      Mod+Equal       { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // Mouse wheel workspace/column navigation
      Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }
      Mod+WheelScrollRight      { focus-column-right; }
      Mod+WheelScrollLeft       { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft  { move-column-left; }
      Mod+Shift+WheelScrollDown { focus-column-right; }
      Mod+Shift+WheelScrollUp   { focus-column-left; }

      // Screenshots
      Print      { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print  { screenshot-window; }

      // Keyboard shortcuts inhibit escape hatch
      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

      // Quit niri
      Mod+Shift+E { quit; }
    }
  '';
}
