{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "darrint-utils";
  version = "0.0.1";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    install zv $out/bin/zv
  '';
}
