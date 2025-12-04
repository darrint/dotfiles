{
  pkgs,
  lib,
  ...
}: let
  # Create the FHS environment with all required libraries
  fhsEnv = pkgs.buildFHSEnv {
    name = "x-plane-12-fhs";

    targetPkgs = pkgs:
      with pkgs; [
        # Core C/C++ libraries
        stdenv.cc.cc # libstdc++.so.6, libgcc_s.so.1
        glibc # libc.so.6, libm.so.6

        # GTK3 Stack (UI Framework)
        gtk3 # libgtk-3.so.0, libgdk-3.so.0
        gdk-pixbuf # libgdk_pixbuf-2.0.so.0
        pango # libpango-1.0.so.0, libpangocairo-1.0.so.0
        harfbuzz # libharfbuzz.so.0
        atk # libatk-1.0.so.0
        cairo # libcairo.so.2, libcairo-gobject.so.2
        glib # libglib-2.0.so.0, libgobject-2.0.so.0, libgio-2.0.so.0

        # X11 Window System
        xorg.libX11 # libX11.so.6
        xorg.libXext # libXext.so.6
        xorg.libXrandr # libXrandr.so.2
        xorg.libXcursor # libXcursor.so.1
        xorg.libXinerama # libXinerama.so.1
        xorg.libXcomposite # libXcomposite.so.1
        xorg.libXdamage # libXdamage.so.1
        xorg.libXfixes # libXfixes.so.3
        xorg.libxcb # libxcb.so.1

        # Graphics Stack (Critical for flight sim!)
        mesa # libgbm.so.1, OpenGL/EGL
        libgbm
        libdrm # libdrm.so.2
        libglvnd # libGL.so.1, OpenGL dispatch
        vulkan-loader # Vulkan support

        # NSS/NSPR (Chromium Embedded Framework)
        nss # libnss3.so, libnssutil3.so, libsmime3.so
        nspr # libnspr4.so

        # System Libraries
        dbus # libdbus-1.so.3
        expat # libexpat.so.1
        libxkbcommon # libxkbcommon.so.0

        # Audio
        alsa-lib # libasound.so.2
        libpulseaudio # PulseAudio support

        # Accessibility
        at-spi2-atk # libatk-bridge-2.0.so.0
        at-spi2-core # libatspi.so.0

        # Printing (for flight plans, charts, etc.)
        cups # libcups.so.2

        # Additional dependencies
        zlib
        curl
        openssl
      ];

    profile = ''
      export XPLANE_DIR="$HOME/X-Plane 12"
    '';

    runScript = "bash";
  };

  # Main X-Plane 12 simulator launcher
  x-plane-launcher = pkgs.writeShellScriptBin "x-plane-12" ''
    if [ ! -d "$HOME/X-Plane 12" ]; then
      echo "Error: X-Plane 12 not found at $HOME/X-Plane 12" >&2
      exit 1
    fi
    cd "$HOME/X-Plane 12" || exit 1
    exec ${fhsEnv}/bin/x-plane-12-fhs -c './X-Plane-x86_64 "$@"' -- "$@"
  '';

  # Plane Maker aircraft editor launcher
  plane-maker-launcher = pkgs.writeShellScriptBin "x-plane-plane-maker" ''
    if [ ! -d "$HOME/X-Plane 12" ]; then
      echo "Error: X-Plane 12 not found at $HOME/X-Plane 12" >&2
      exit 1
    fi
    cd "$HOME/X-Plane 12" || exit 1
    exec ${fhsEnv}/bin/x-plane-12-fhs -c './Plane\ Maker-x86_64 "$@"' -- "$@"
  '';

  # Airfoil Maker airfoil designer launcher
  airfoil-maker-launcher = pkgs.writeShellScriptBin "x-plane-airfoil-maker" ''
    if [ ! -d "$HOME/X-Plane 12" ]; then
      echo "Error: X-Plane 12 not found at $HOME/X-Plane 12" >&2
      exit 1
    fi
    cd "$HOME/X-Plane 12" || exit 1
    exec ${fhsEnv}/bin/x-plane-12-fhs -c './Airfoil\ Maker-x86_64 "$@"' -- "$@"
  '';

  # Desktop entry for main X-Plane 12 simulator
  x-plane-desktop = pkgs.makeDesktopItem {
    name = "x-plane-12";
    desktopName = "X-Plane 12";
    comment = "Professional Flight Simulator";
    exec = "x-plane-12";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = ["Game" "Simulation"];
  };

  # Desktop entry for Plane Maker
  plane-maker-desktop = pkgs.makeDesktopItem {
    name = "x-plane-plane-maker";
    desktopName = "X-Plane Plane Maker";
    comment = "X-Plane Aircraft Editor";
    exec = "x-plane-plane-maker";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = ["Game" "Simulation" "Utility"];
  };

  # Desktop entry for Airfoil Maker
  airfoil-maker-desktop = pkgs.makeDesktopItem {
    name = "x-plane-airfoil-maker";
    desktopName = "X-Plane Airfoil Maker";
    comment = "X-Plane Airfoil Designer";
    exec = "x-plane-airfoil-maker";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = ["Game" "Simulation" "Utility"];
  };
in
  # Combine all components into a single package
  pkgs.symlinkJoin {
    name = "x-plane-12";
    paths = [
      x-plane-launcher
      plane-maker-launcher
      airfoil-maker-launcher
      x-plane-desktop
      plane-maker-desktop
      airfoil-maker-desktop
    ];

    meta = with lib; {
      description = "FHS environment launchers for X-Plane 12 flight simulator";
      longDescription = ''
        Provides command-line launchers and desktop integration for X-Plane 12
        running on NixOS. Includes launchers for the main simulator, Plane Maker
        aircraft editor, and Airfoil Maker airfoil designer.

        X-Plane 12 must be installed at $HOME/X-Plane 12
      '';
      homepage = "https://www.x-plane.com/";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = [];
      mainProgram = "x-plane-12";
    };
  }
