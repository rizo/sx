{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = [
    pkgs.pkg-config
    pkgs.pcre
  ];
}
