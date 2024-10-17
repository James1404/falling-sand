{
  description = "Meridian Programming Language";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
  };

  outputs = { self, flake-utils, nixpkgs, zig, zls, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          zlspkg = zls.packages.${system};
          pkgs = import nixpkgs { inherit system; overlays = [zig.overlays.default];  };
        in {
          devShells.default = (pkgs.mkShell.override
            { stdenv = pkgs.clangStdenv; }
            {
              packages = with pkgs; [
                zigpkgs.master
                zlspkg.default

                lldb

                raylib

                xorg.libX11
                xorg.libX11.dev
                xorg.libXft
                xorg.libXrandr
                xorg.libXinerama
                xorg.libXcursor
                xorg.libXi
                
                lua-language-server
              ];
            }
          );
        }
      );
}
