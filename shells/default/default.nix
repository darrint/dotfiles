{ pkgs, mkShell, ... }:
mkShell {
  packages = [ pkgs.sops pkgs.age ];
}
