{
  description = "falling sand";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [(import rust-overlay)];
            config.allowUnfree = true;
          };
          packages = with pkgs; [
            pkg-config
            lldb
            gdb

            (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
              extensions = [ "rust-analyzer" "rust-src" ];
            }))

            cargo-udeps
            clippy

            libGL
            xorg.libX11
            xorg.libXi
            libxkbcommon
            alsa-lib.dev

            aseprite
          ];
        in {
          devShells.default = (pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
            inherit packages;



            RUST_BACKTRACE = "1";
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;
          });
        }
      );
}
