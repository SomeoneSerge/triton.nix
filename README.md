# Nix rules for the [triton inference server](https://github.com/triton-inference-server/server)

## Status

- [x] [microsoft/onnxruntime](https://github.com/microsoft/onnxruntime)
    - [ ] Build as is, using upstream's script
    - [ ] Wrap all submodules separately, discard the `build.py`
- [ ] [onnxruntime_backend](https://github.com/triton-inference-server/onnxruntime_backend)
      ```
      ...
      triton-onnxruntime_backend> CMake Error at cmake_install.cmake:90 (file):
      triton-onnxruntime_backend>   file INSTALL cannot find "/build/source/build/onnxruntime": No such file or
      triton-onnxruntime_backend>   directory.
      ```
- [ ] ...
- [ ] [server](https://github.com/triton-inference-server/server)
