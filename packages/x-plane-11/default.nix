{
  pkgs,
  lib,
  ...
}: let
  # Create the FHS environment with all required libraries
  fhsEnv = pkgs.buildFHSEnv {
    name = "x-plane-11-fhs";

    targetPkgs = pkgs:
      with pkgs; [
        # Core C/C++ libraries
        stdenv.cc.cc # libstdc++.so.6, libgcc_s.so.1
        glibc # libc.so.6, libm.so.6

        # GTK2 Stack (X-Plane 11 uses GTK2)
        gtk2
        gdk-pixbuf
        pango
        cairo
        atk
        glib

        # X11 Window System
        xorg.libX11
        xorg.libXext
        xorg.libXrandr
        xorg.libXcursor
        xorg.libXinerama
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXfixes
        xorg.libxcb
        xorg.libXi
        xorg.libXxf86vm
        xorg.libXrender

        # Graphics Stack (OpenGL support for NVIDIA GPU)
        mesa # Provides OpenGL implementation
        libGLU # OpenGL Utility Library
        libgbm # Generic Buffer Management
        libdrm # Direct Rendering Manager
        libglvnd # OpenGL vendor-neutral dispatch (routes to NVIDIA or Mesa)

        # System Libraries
        dbus
        expat
        libxkbcommon

        # Audio
        alsa-lib
        libpulseaudio

        # Additional dependencies
        zlib
        curl
        openssl
        freetype
        fontconfig
      ];

    profile = ''
      export XPLANE_DIR="$HOME/Games/X-Plane 11"
      
      # Force NVIDIA GPU usage via PRIME render offload
      # X-Plane 11 uses OpenGL, which the NVIDIA Quadro M1200 fully supports
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      
      # Ensure NVIDIA driver is used
      export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
      
      # Performance settings
      export __GL_SYNC_TO_VBLANK=0
      export __GL_THREADED_OPTIMIZATIONS=1
    '';

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
    comment = "Professional Flight Simulator (NVIDIA GPU)";
    exec = "x-plane-11";
    icon = "applications-games";
    terminal = false;
    type = "Application";
    categories = ["Game" "Simulation"];
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
    categories = ["Game" "Simulation" "Utility"];
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
    categories = ["Game" "Simulation" "Utility"];
  };
in
  # Combine all components into a single package
  pkgs.symlinkJoin {
    name = "x-plane-11";
    paths = [
      x-plane-launcher
      plane-maker-launcher
      airfoil-maker-launcher
      x-plane-desktop
      plane-maker-desktop
      airfoil-maker-desktop
    ];

    meta = with lib; {
      description = "FHS environment launchers for X-Plane 11 flight simulator with NVIDIA GPU support";
      longDescription = ''
        Provides command-line launchers and desktop integration for X-Plane 11
        running on NixOS with NVIDIA GPU acceleration via OpenGL.

        X-Plane 11 must be installed at $HOME/Games/X-Plane 11

        This package is configured to use the NVIDIA Quadro M1200 GPU via
        PRIME render offload, providing significantly better performance than
        the integrated Intel GPU.
      '';
      homepage = "https://www.x-plane.com/";
      license = licenses.unfree;
      platforms = platforms.linux;
      maintainers = [];
      mainProgram = "x-plane-11";
    };
  }
