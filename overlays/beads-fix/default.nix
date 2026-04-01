{ inputs, ... }:
final: prev:
let
  beadsFlake = inputs.beads-ai;
  # nixpkgs 25.11 ships Go 1.25.7, but charm.land/huh/v2 requires >= 1.25.8.
  # Use buildGo126Module so the version constraint is satisfied.
  # Also fix the vendorHash (wrong in upstream) and add icu for the CGO dependency.
in
{
  beads-ai =
    (prev.callPackage (beadsFlake + "/default.nix") {
      self = beadsFlake;
      buildGoModule = prev.buildGo126Module;
    }).overrideAttrs
      (old: {
        vendorHash = "sha256-GYPfvsI8eNJbdzrbO7YnMkN2Yt6KZNB7w/2SJD2WdFY=";
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.pkg-config ];
        buildInputs = (old.buildInputs or [ ]) ++ [ prev.icu ];
      });
}
