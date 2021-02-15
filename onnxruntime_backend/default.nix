{
  pkgs ? import <nixpkgs> { },
  microsoft-onnxruntime,
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
      (substituteAll {
        src = ./dont-run-docker.patch;
        onnxRuntime = microsoft-onnxruntime;
        onnxRuntimeTest = microsoft-onnxruntime.test;
      })
    ];
    postPatch = ''
      patchShebangs tools/
      '';
    cmakeFlags = [
      "-DCMAKE_INSTALL_PREFIX:PATH=${placeholder "out"}/"
      "-DTRITON_ONNXRUNTIME_INCLUDE_PATHS=${microsoft-onnxruntime}/include"
      "-DTRITON_ONNXRUNTIME_LIB_PATHS=${microsoft-onnxruntime}/lib"
      # "-DTRITON_BUILD_ONNXRUNTIME_VERSION=1.6.0"
      # "-DTRITON_BUILD_CONTAINER_VERSION=21.02"
      # "-DTRITON_ENABLE_ONNXRUNTIME_TENSORRT=ON"
      # "-DTRITON_ENABLE_ONNXRUNTIME_OPENVINO=ON"
      # "-DTRITON_BUILD_ONNXRUNTIME_OPENVINO_VERSION=2021.1"
      # "-DCMAKE_CXX_FLAGS=-I${microsoft-onnxruntime}/include"
      # "-DLDFLAGS=-L${microsoft-onnxruntime}/lib"
    ];
  };
in ort-backend
