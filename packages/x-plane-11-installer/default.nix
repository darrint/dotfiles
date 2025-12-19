{
  pkgs,
  lib,
  ...
}: let
  # FHS environment for X-Plane 11 installer
  fhsEnv = pkgs.buildFHSEnv {
    name = "x-plane-11-installer-fhs";

    targetPkgs = pkgs:
      with pkgs; [
        # GTK2 Stack (installer needs GTK2)
        gtk2
        glib
        pango
        cairo
        gdk-pixbuf
        atk

        # OpenGL/GLU
        libGLU
        mesa
        libGL
        libglvnd

        # X11
        xorg.libX11
        xorg.libXext
        xorg.libXrender

        # Additional dependencies
        stdenv.cc.cc
        glibc
        zlib
        freetype
        fontconfig
      ];

    runScript = "bash";
  };

  installer-wrapper = pkgs.writeShellScriptBin "x-plane-11-installer" ''
    if [ $# -eq 0 ]; then
      echo "Usage: x-plane-11-installer <path-to-installer-binary>"
      echo "Example: x-plane-11-installer ~/Downloads/X-Plane\ 11\ Installer\ Linux"
      exit 1
    fi
    
    INSTALLER_PATH="$1"
    shift
    
    if [ ! -f "$INSTALLER_PATH" ]; then
      echo "Error: Installer not found at: $INSTALLER_PATH"
      exit 1
    fi
    
    # Make sure it's executable
    chmod +x "$INSTALLER_PATH"
    
    # Run in FHS environment
    exec ${fhsEnv}/bin/x-plane-11-installer-fhs -c "'$INSTALLER_PATH' \"\$@\"" -- "$@"
  '';
in
  installer-wrapper
