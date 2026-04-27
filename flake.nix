{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kast.url = "git+https://github.com/kast-lang/kast?ref=self-host&submodules=1";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = import inputs.nixpkgs { inherit system overlays; };
        kast = inputs.kast.packages.${system}.default;
      in
      with pkgs; {
        devShells.default = mkShell {
          packages = [
            kast
            nixfmt-classic
            just
            fd
            gcc
            clang
            # boehmgc
            (raylib.overrideAttrs (oa: {
              version = "6.0";
              src = fetchFromGitHub {
                owner = "raysan5";
                repo = "raylib";
                rev = "72a341a37fbd9ccc1d8ec284ff20aeb5b991ad75";
                hash = "sha256-NEWR8BLRlCHZmg3T0BDcvDcAqAUSx0ooeehwaRpqfcg=";
              };
              propagatedBuildInputs = oa.propagatedBuildInputs ++ [ libxrandr ];
            }))
            emscripten
            caddy
            butler
          ];
          shellHook = ''
            echo Hello from Kast dev shell
          '';
          # Since I dont have cmake or whatever
          CLANGD_FLAGS = "--query-driver=${pkgs.clang}/bin/clang*";
          RAYLIB = "${raylib}";
          RAYLIB_WEB = "${inputs.kast.packages.${system}.raylib-web}/libraylib.web.a";
          KAST_PATH = "${inputs.kast.packages.${system}.kast-path}";
        };
      });
}
