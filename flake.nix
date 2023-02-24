{
  description = "An offline ray-tracer written in Rust";
   
  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, flake-compat, nixpkgs, rust-overlay, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        pkg-version = (builtins.fromTOML (builtins.readFile ./Cargo.toml)).package.version;
        rust-version = "1.67.1";
        rust-dist = pkgs.rust-bin.stable.${rust-version}.default.override {
          extensions = [ "clippy" "rust-src" "rustfmt" "rust-analyzer" ];
          targets = [ "x86_64-unknown-linux-gnu" ];
        };
      in {
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "discovery";
          version = pkg-version;
          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };
  
        defaultApp = utils.lib.mkApp {
          drv = self.defaultPackage."${system}";
        };

        devShell = with pkgs; mkShell {
          buildInputs = [
            # Project tools
            cargo-msrv
            # Nix
            nixfmt
            # Rust
            rust-dist
          ];

          shellHook = ''
  
          '';
  
          RUST_BACKTRACE = "1";
        };
      }
    );
  }