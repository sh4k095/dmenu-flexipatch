{
  description = "Nix flake for my fork of dmenu";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { pkgs, self', ... }:
        {
          packages.dmenu = pkgs.stdenv.mkDerivation {
            pname = "dmenu";
            version = "5.4";

            src = ./.;

            nativeBuildInputs = [ pkgs.pkg-config ];

            buildInputs = with pkgs; [
              libx11
              libxinerama
              libxft
              fontconfig
              freetype
            ];

            postPatch = ''
              sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run dmenu_path
            '';

            makeFlags = [
              "CC=${pkgs.stdenv.cc.targetPrefix}cc"
              "PREFIX=$(out)"
              "X11INC=${pkgs.libx11.dev}/include"
              "X11LIB=${pkgs.libx11}/lib"
              "FREETYPEINC=${pkgs.freetype.dev}/include/freetype2"
            ];

            meta = {
              description = "Dynamic menu for X (flexipatch build)";
              homepage = "https://github.com/sh4k095/dmenu-flexipatch";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.unix;
              mainProgram = "dmenu";
            };
          };

          packages.default = self'.packages.dmenu;

          devShells.default = pkgs.mkShell {
            inputsFrom = [ self'.packages.dmenu ];

            MAKEFLAGS = toString [
              "X11INC=${pkgs.libx11.dev}/include"
              "X11LIB=${pkgs.libx11}/lib"
              "FREETYPEINC=${pkgs.freetype.dev}/include/freetype2"
            ];
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
