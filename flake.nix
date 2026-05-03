{
  description = "btop - a monitor of resources";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        isDarwin = pkgs.stdenv.isDarwin;

        btop = pkgs.stdenv.mkDerivation {
          pname = "btop";
          version = "1.4.0";

          src = ./.;

          nativeBuildInputs = [
            pkgs.cmake
            pkgs.lowdown
          ];

          buildInputs = pkgs.lib.optionals isDarwin [
            pkgs.darwin.apple_sdk.frameworks.CoreFoundation
            pkgs.darwin.apple_sdk.frameworks.IOKit
          ];

          cmakeFlags = [
            "-DBTOP_GPU=${if isDarwin then "ON" else "OFF"}"
            "-DBTOP_LTO=ON"
          ];

          meta = {
            description = "Resource monitor that shows usage and stats for processor, memory, disks, network and processes";
            homepage = "https://github.com/aristocratos/btop";
            license = pkgs.lib.licenses.asl20;
            mainProgram = "btop";
            platforms = pkgs.lib.platforms.unix;
          };
        };
      in
      {
        packages = {
          inherit btop;
          default = btop;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ btop ];
          packages = [
            pkgs.clang-tools  # clangd, clang-format
            pkgs.cmake-format
          ];
        };
      });
}
