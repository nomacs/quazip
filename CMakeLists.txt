cmake_minimum_required(VERSION 2.6)
project(QuaZip)

# CMP0042: Explicitly acknowledge MACOSX_RPATH
# (introduced in CMake 2.8.12, enabled by default in CMake 3.0,
# and producing a warning when unset since 3.7.1)
cmake_policy(SET CMP0042 NEW)

# load paths from the user file if exists
if (EXISTS ${CMAKE_SOURCE_DIR}/CMakeUserPaths.cmake)
	include(${CMAKE_SOURCE_DIR}/CMakeUserPaths.cmake)
elseif(MSVC)
	message(WARNING "Could not find CMakeUserPaths.cmake - please use this file to specify your install directories (see CMakeUserPathsGit.cmake)")
endif()

# nomacs config
SET(ZLIB_LIBRARIES optimized "${ZLIB_BUILD_PATH}/lib/Release/zlib.lib" debug "${ZLIB_BUILD_PATH}/lib/Debug/zlibd.lib")

option(BUILD_WITH_QT4 "Build QuaZip with Qt4 no matter if Qt5 was found" OFF)

if( NOT BUILD_WITH_QT4 )

    # locate qmake - this is for nomacs config...
    if(NOT QT_QMAKE_EXECUTABLE)
    find_program(QT_QMAKE_EXECUTABLE NAMES "qmake" "qmake-qt5" "qmake.exe")
    endif()
    if(NOT QT_QMAKE_EXECUTABLE)
    message(FATAL_ERROR "you have to set the path to the Qt5 qmake executable in CMakeUserPaths.cmake")
    else()
    message(STATUS "QMake found: ${QT_QMAKE_EXECUTABLE}")
    endif()

    get_filename_component(QT_QMAKE_PATH ${QT_QMAKE_EXECUTABLE} PATH)

    set(QT_ROOT ${QT_QMAKE_PATH}/)
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${QT_QMAKE_PATH}/../lib/cmake/Qt5)

    find_package(Qt5 COMPONENTS Core Gui REQUIRED)


    # try Qt5 first, and prefer that if found
    find_package(Qt5Core REQUIRED)
endif()

if(Qt5Core_FOUND)
    set(CMAKE_CXX_STANDARD 11)
    set(QTCORE_LIBRARIES ${Qt5Core_LIBRARIES})
    set(QUAZIP_LIB_VERSION_SUFFIX 5)
    # if there is no QT_ROOT, try to deduce it from Qt QtCore include
    if("${QT_ROOT}" STREQUAL "")
        set(QT_ROOT ${QT_QTCORE_INCLUDE_DIR}/../..)
    endif()
    include_directories(${Qt5Core_INCLUDE_DIRS})

    macro(qt_wrap_cpp)
        qt5_wrap_cpp(${ARGN})
    endmacro()
elseif(BUILD_WITH_QT4)
    set(qt_min_version "4.5.0")
    find_package(Qt4 REQUIRED)
    set(QT_USE_QTGUI false)
    include(${QT_USE_FILE})
    include_directories(${QT_INCLUDES})
    set(QTCORE_LIBRARIES ${QT_QTCORE_LIBRARY})

    macro(qt_wrap_cpp)
        qt4_wrap_cpp(${ARGN})
    endmacro()
endif()

# Use system zlib on unix and Qt ZLIB on Windows
if(UNIX OR MINGW)
    find_package(ZLIB REQUIRED)
else(UNIX OR MINGW)
    set(ZLIB_INCLUDE_DIRS "${QT_ROOT}/src/3rdparty/zlib" CACHE STRING "Path to ZLIB headers of Qt")
    # set(ZLIB_LIBRARIES "")  # empty zlib is only working for x86

    if(NOT EXISTS "${ZLIB_INCLUDE_DIRS}/zlib.h")
        set(ZLIB_INCLUDE_DIRS ${ZLIB_INCLUDE_DIR})	# take the one from the user
    endif(NOT EXISTS "${ZLIB_INCLUDE_DIRS}/zlib.h")

    if(NOT EXISTS "${ZLIB_INCLUDE_DIRS}/zlib.h")
        message(WARNING "cannot find ${ZLIB_INCLUDE_DIRS}/zlib.h")
        message("Please specify a valid zlib include dir")
    endif(NOT EXISTS "${ZLIB_INCLUDE_DIRS}/zlib.h")
endif(UNIX OR MINGW)

# All build libraries are moved to this directory
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})

set(LIB_SUFFIX "" CACHE STRING "Define suffix of directory name (32/64)")
set(LIB_DESTINATION "${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}" CACHE STRING "Library directory name" FORCE)
set(QUAZIP_LIB_TARGET_NAME quazip${QUAZIP_LIB_VERSION_SUFFIX} CACHE
    INTERNAL "Target name of libquazip" FORCE)

add_subdirectory(quazip)


# write nomacs config file

# install(FILES FindQuaZip.cmake RENAME FindQuaZip${QUAZIP_LIB_VERSION_SUFFIX}.cmake DESTINATION ${CMAKE_ROOT}/Modules)
get_property(QUAZIP_DEBUG_NAME TARGET ${QUAZIP_LIB_TARGET_NAME} PROPERTY DEBUG_OUTPUT_NAME)
get_property(QUAZIP_RELEASE_NAME TARGET ${QUAZIP_LIB_TARGET_NAME} PROPERTY RELEASE_OUTPUT_NAME)
SET(QUAZIP_LIBRARIES optimized ${CMAKE_CURRENT_BINARY_DIR}/Release/${QUAZIP_LIB_TARGET_NAME}.lib debug ${CMAKE_CURRENT_BINARY_DIR}/Debug/${QUAZIP_LIB_TARGET_NAME}d.lib)
SET(QUAZIP_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/quazip/include/)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/QuaZip.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/QuaZipConfig.cmake)
