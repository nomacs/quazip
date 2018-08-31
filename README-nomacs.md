# Building QuaZip for nomacs

## Build QuaZip (Windows)

### Compile dependencies

- [OpenCV](https://github.com/TUWien/opencv) (>= 3.4) _optional_

### Compile Exiv2

- copy `CMakeUserPathsGit.cmake` and rename it to `CMakeUserPaths.cmake`
- add your library paths to the `${CMAKE_PREFIX_PATH}` in `CMakeUserPaths.cmake`
- Open CMake GUI
- set this folder to `where is the source code`
- choose a build folder (e.g. `build2017-x64`)
- Hit `Configure`then `Generate`
- Open the Project
- Compile the Solution (build Release and Debug)
- You should now have an `quazip5.dll` in $YOUR_QUAZIP_BUILD_PATH$/bin
- In the `CMakeUserPaths.cmake` of your [nomacs](https://github.com/nomacs/nomacs) project, add this path:

```cmake
SET(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} "$QUAZIP_PATH$/build2017-x64/")
```
