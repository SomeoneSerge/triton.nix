{
  pkgs ? import <nixpkgs> { },
  lib,
  onnxruntime,
  cudatoolkit,
  cudnn,
  gcc6Stdenv,
  cmake,
  extra-cmake-modules,
  python3,
  python3Packages,
  flatbuffers,
  gtest,
  gmock,
}:

let
  ort = gcc6Stdenv.mkDerivation rec {
    name = "microsoft-onnxruntime";
    src = onnxruntime;
    buildInputs = [cudatoolkit cudnn flatbuffers gtest gmock];
    nativeBuildInputs = [
      cmake extra-cmake-modules
      python3
      python3Packages.flake8
      python3Packages.flatbuffers
    ];
    CMAKE_CXX_FLAGS = ""; # "-D_GLIBCXX_USE_CXX11_ABI=0";
    cmakeFlags = [
      "-DFLATBUFFERS_FLATC_EXECUTABLE=${flatbuffers}/bin/flatc"
      "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}"
    ];
    configurePhase = ''
      cc --version
    '';
    buildPhase =
      let
        stripDashD = builtins.match "^-D(.*)$";
        replaceDashD = x: "--cmake_extra_defines ${builtins.elemAt (stripDashD x) 0}";
        newCmakeFlags = lib.concatMapStringsSep " " replaceDashD cmakeFlags;
      in ''
      python3 ./tools/ci_build/build.py \
        --skip_submodule_sync \
        --parallel \
        --build_shared_lib \
        --use_openmp \
        --build_dir $(pwd)/build \
        --config Release \
        ${newCmakeFlags} \
        --cuda_home "${cudatoolkit}" \
        --cudnn_home "${cudnn}" \
        --use_cuda \
        --update \
        --build
    '';
    outputs = ["out" "test"];
    installPhase = ''
      mkdir -p $out/include $out/lib $out/bin
      mkdir -p $test/lib

      cp -t $out/include \
        ./include/onnxruntime/core/session/onnxruntime_c_api.h \
        ./include/onnxruntime/core/session/onnxruntime_session_options_config_keys.h \
        ./include/onnxruntime/core/providers/cpu/cpu_provider_factory.h \
        ./include/onnxruntime/core/providers/cuda/cuda_provider_factory.h
      cp -t $out/lib \
        ./build/Release/libonnxruntime.so*
      cp -t $out/bin \
        ./build/Release/onnxruntime_perf_test \
        ./build/Release/onnx_test_runner

      chmod a+x $out/bin/*
      patchelf --set-rpath $out/lib $out/bin/*

      cp -t $test/lib ./build/Release/libcustom_op_library.so
      cp -t $test ./build/Release/testdata/custom_op_library/custom_op_test.onnx
      ln -sf ./lib/libcustom_op_library.so $test/
    '';
  };
in ort
