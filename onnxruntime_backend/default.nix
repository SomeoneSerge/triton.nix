{
  pkgs ? import <nixpkgs> { },
  onnxruntime-backend,
  repo-core,
  repo-common,
  repo-backend,
  substituteAll,
  cudatoolkit,
  rapidjson,
  cmake,
  extra-cmake-modules,
  python3,
}:

let
  ort-backend = pkgs.stdenv.mkDerivation {
    name = "triton-onnxruntime_backend";
    src = onnxruntime-backend;
    buildInputs = [cudatoolkit rapidjson];
    nativeBuildInputs = [cmake extra-cmake-modules python3];
    patches = [
      (substituteAll {
        src = ./dont-fetchcontent.patch;
        repoCommon = repo-common;
        repoCore = repo-core;
        repoBackend = repo-backend;
      })
    ];
    postPatch = ''
      patchShebangs tools/
      '';
    cmakeFlags = [
      "-DCMAKE_INSTALL_PREFIX:PATH=$out/"
      "-DTRITON_BUILD_ONNXRUNTIME_VERSION=1.6.0"
      "-DTRITON_BUILD_CONTAINER_VERSION=21.02"
      "-DTRITON_ENABLE_ONNXRUNTIME_TENSORRT=ON"
      # "-DTRITON_ENABLE_ONNXRUNTIME_OPENVINO=ON"
      # "-DTRITON_BUILD_ONNXRUNTIME_OPENVINO_VERSION=2021.1"
    ];
  };
in ort-backend
