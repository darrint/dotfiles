{ inputs, pkgs, ... }:
  pkgs.stdenvNoCC.mkDerivation {
    pname = "hyprland-config";
    version = "0.0.1";

    src = inputs.hyprland-starter;
    installPhase = ''
      mkdir -p $out/src
      cp --preserve=mode,timestamps --recursive $src/* $out/src
    '';
  }
