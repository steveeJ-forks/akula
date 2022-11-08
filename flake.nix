# This file is pretty general, and you can adapt it in your project replacing
# only `name` and `description` below.

{
  description = "akula";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fenix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        toolchain = fenix.packages.${system}.minimal.toolchain;
        pkgs = nixpkgs.legacyPackages.${system};

        cargoToml = (builtins.fromTOML (builtins.readFile ./Cargo.toml));

        rustPlatform = pkgs.makeRustPlatform {
          cargo = toolchain;
          rustc = toolchain;
        };

        akulaPackage = rustPlatform.buildRustPackage {
          pname = cargoToml.package.name;
          version = cargoToml.package.version;

          src = pkgs.lib.sources.cleanSource ./.;
          cargoSha256 = "sha256-9GPWkdr1zI3G05RwfD1L7FKVcZeinpzwPmYNSM5tk2Q=";

          doCheck = false;

          buildNoDefaultFeatures = true;

          nativeBuildInputs = [ pkgs.pkg-config pkgs.clang_12 ];

          buildInputs = [ pkgs.e2fsprogs pkgs.llvmPackages_12.libclang.lib ];

          LIBCLANG_PATH = "${pkgs.llvmPackages_12.libclang.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS = ''
            -isystem ${pkgs.llvmPackages_12.libclang.lib}/lib/clang/${
              pkgs.lib.getVersion pkgs.clang_12
            }/include

            -isystem ${pkgs.llvmPackages_12.libclang.out}/lib/clang/${
              pkgs.lib.getVersion pkgs.clang_12
            }/include

            -isystem ${pkgs.e2fsprogs.dev}/include

            -isystem ${pkgs.glibc.dev}/include
          '';
        };

      in {
        defaultPackage = akulaPackage;
        defaultApp = akulaPackage;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ akulaPackage ];
          packages = [ pkgs.nixfmt ];
        };
      });
}
