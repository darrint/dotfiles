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
    imagemagick # wallpaper processing
    cliphist # clipboard history (wl-clipboard is in darrint-gui)
    wlsunset # night light
    # noctalia kept as an optional fallback; run manually with: noctalia-shell
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
