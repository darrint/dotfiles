{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "dotfiles";
  version = "0.0.1";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    install installdotfiles $out/bin
    cp -r config/ $out/bin/config
  '';
}
