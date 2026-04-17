{
  pkgs,
  lib,
  ...
}:
let
  # Create the FHS environment - based on working installer config
  fhsEnv = pkgs.buildFHSEnv {
    name = "x-plane-11-fhs";

    targetPkgs =
      pkgs: with pkgs; [
        # Core C/C++ libraries
        stdenv.cc.cc
        glibc

        # GTK2 Stack (X-Plane 11 uses GTK2)
        gtk2
        glib
        pango
        cairo
        gdk-pixbuf
        atk

        # OpenGL/GLU (same as installer that works)
        libGLU
        mesa
        libGL
        libglvnd

        # X11 Window System
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libXrandr
        xorg.libXcursor
        xorg.libXi
        xorg.libXxf86vm
        xorg.libXinerama
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXfixes
        xorg.libxcb

        # System Libraries
        dbus
        expat
        libxkbcommon
        zlib
        freetype
        fontconfig

        # Audio
        alsa-lib
        libpulseaudio
        openal

        # Network
        curl
        openssl
      ];

    runScript = "bash";
  };

  # Main X-Plane 11 simulator launcher
  x-plane-launcher = pkgs.writeShellScriptBin "x-plane-11" ''
    if [ ! -d "$HOME/Games/X-Plane 11" ]; then
      echo "Error: X-Plane 11 not found at $HOME/Games/X-Plane 11" >&2
      exit 1
    fi
    cd "$HOME/Games/X-Plane 11" || exit 1

    exec ${fhsEnv}/bin/x-plane-11-fhs -c './X-Plane-x86_64 "$@"' -- "$@"
  '';

  # NVIDIA GPU launcher
  x-plane-nvidia-launcher = pkgs.writeShellScriptBin "x-plane-11-nvidia" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    exec x-plane-11 "$@"
  '';

  # Plane Maker aircraft editor launcher
  plane-maker-launcher = pkgs.writeShellScriptBin "x-plane-11-plane-maker" ''
    if [ ! -d "$HOME/Games/X-Plane 11" ]; then
      echo "Error: X-Plane 11 not found at $HOME/Games/X-Plane 11" >&2
      exit 1
    fi
    cd "$HOME/Games/X-Plane 11" || exit 1

    exec ${fhsEnv}/bin/x-plane-11-fhs -c './Plane-Maker-x86_64 "$@"' -- "$@"
  '';

  # Airfoil Maker airfoil designer launcher
  airfoil-maker-launcher = pkgs.writeShellScriptBin "x-plane-11-airfoil-maker" ''
    if [ ! -d "$HOME/Games/X-Plane 11" ]; then
      echo "Error: X-Plane 11 not found at $HOME/Games/X-Plane 11" >&2
      exit 1
    fi
    cd "$HOME/Games/X-Plane 11" || exit 1

    exec ${fhsEnv}/bin/x-plane-11-fhs -c './Airfoil-Maker-x86_64 "$@"' -- "$@"
  '';

  # Desktop entry for main X-Plane 11 simulator
  x-plane-desktop = pkgs.makeDesktopItem {
    name = "x-plane-11";
    desktopName = "X-Plane 11";
    comment = "Professional Flight Simulator";
    exec = "x-plane-11 --disable_networking";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = [
      "Game"
      "Simulation"
    ];
  };

  # Desktop entry for NVIDIA version
  x-plane-nvidia-desktop = pkgs.makeDesktopItem {
    name = "x-plane-11-nvidia";
    desktopName = "X-Plane 11 (NVIDIA)";
    comment = "Professional Flight Simulator with NVIDIA GPU";
    exec = "x-plane-11-nvidia";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = [
      "Game"
      "Simulation"
    ];
  };

  # Desktop entry for Plane Maker
  plane-maker-desktop = pkgs.makeDesktopItem {
    name = "x-plane-11-plane-maker";
    desktopName = "X-Plane 11 Plane Maker";
    comment = "X-Plane Aircraft Editor";
    exec = "x-plane-11-plane-maker";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = [
      "Game"
      "Simulation"
      "Utility"
    ];
  };

  # Desktop entry for Airfoil Maker
  airfoil-maker-desktop = pkgs.makeDesktopItem {
    name = "x-plane-11-airfoil-maker";
    desktopName = "X-Plane 11 Airfoil Maker";
    comment = "X-Plane Airfoil Designer";
    exec = "x-plane-11-airfoil-maker";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = [
      "Game"
      "Simulation"
      "Utility"
    ];
  };
in
# Combine all components into a single package
pkgs.symlinkJoin {
  name = "x-plane-11";
  paths = [
    x-plane-launcher
    x-plane-nvidia-launcher
    plane-maker-launcher
    airfoil-maker-launcher
    x-plane-desktop
    x-plane-nvidia-desktop
    plane-maker-desktop
    airfoil-maker-desktop
  ];

  meta = with lib; {
    description = "FHS environment launcher for X-Plane 11 with NVIDIA GPU support";
    longDescription = ''
      Launcher for X-Plane 11 running on NixOS with NVIDIA GPU
      acceleration via OpenGL.

      X-Plane 11 must be installed at $HOME/Games/X-Plane 11

      This package is configured to use the NVIDIA Quadro M1200 GPU via
      PRIME render offload for significantly better performance.
    '';
    homepage = "https://www.x-plane.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
    mainProgram = "x-plane-11";
  };
}
