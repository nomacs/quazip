# If you want to use prefix paths with cmake, copy and rename this file to CMakeUser.cmake
# Do not add this file to GIT!

SET(ZLIB_INCLUDE_DIR "C:/coding/3rd-party/opencv/3rdparty/zlib")

# set your preferred OpenCV Library path
IF (CMAKE_CL_64)
	message(STATUS "using x64 architecture...")

	# we use opencv's zlib
	SET(ZLIB_BUILD_PATH "C:/coding/3rd-party/opencv/build2017-x64/3rdparty")
	SET(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} "C:/Qt/Qt5.11.1-x64/lib/cmake/Qt5Core")
ELSE()

	message(STATUS "using x86 architecture...")

	# we use opencv's zlib
	SET(ZLIB_BUILD_PATH "C:/coding/3rd-party/opencv/build2017-x86/3rdparty")
	SET(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} "C:/Qt/Qt5.11.1-x86/lib/cmake/Qt5Core")
ENDIF()

SET(ZLIB_LIBRARIES optimized "${ZLIB_BUILD_PATH}/lib/Release/zlib.lib" debug "${ZLIB_BUILD_PATH}/lib/Debug/zlibd.lib")