{
  description = "Triton inference server ONNX runtime backend";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.onnxruntime = {
    url = "https://github.com/microsoft/onnxruntime.git";
    flake = false;
    type = "git";
    submodules = true;
  };
  inputs.onnxruntime-backend = {
    url = "github:triton-inference-server/onnxruntime_backend";
    flake = false;
  };
  inputs.repo-common = {
    url = "github:triton-inference-server/common";
    flake = false;
  };
  inputs.repo-core = {
    url = "github:triton-inference-server/core";
    flake = false;
  };
  inputs.repo-backend = {
    url = "github:triton-inference-server/backend";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs: flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs { inherit system; };
    pkgsUnfree = import nixpkgs { inherit system; config.allowUnfree = true; };
    onnxruntime = with pkgsUnfree; callPackage ./onnxruntime/default.nix { inherit (inputs) onnxruntime; };
    onnxruntime-backend = with pkgsUnfree; callPackage ./onnxruntime_backend/default.nix { inherit (inputs) onnxruntime-backend repo-core repo-common repo-backend; };
  in rec {
    packages.onnxruntime = onnxruntime;
    packages.onnxruntime-backend = onnxruntime-backend;
    defaultPackage = packages.onnxruntime;
  });
}
